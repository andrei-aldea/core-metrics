#!/usr/bin/env python3
"""Verify this repository's deterministic artwork and retained source pixels."""
import hashlib
import json
import struct
import subprocess
import sys
from pathlib import Path


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def dimensions(path):
    result = subprocess.run(['sips', '-g', 'pixelWidth', '-g', 'pixelHeight', str(path)],
                            check=True, capture_output=True, text=True)
    values = {}
    for line in result.stdout.splitlines():
        if ':' in line:
            key, value = line.strip().split(':', 1)
            if key in ('pixelWidth', 'pixelHeight'):
                values[key] = int(value)
    return values['pixelWidth'], values['pixelHeight']


def check(condition, reason):
    if not condition:
        raise ValueError(reason)


def main():
    root = Path(__file__).resolve().parents[2]
    pack = root / 'docs/app-store/screenshots/marketing-build9'
    manifest = json.loads((pack / 'manifest.json').read_text())
    config_file = pack / 'artwork.json'
    config = json.loads(config_file.read_text())
    check(sha256(config_file) == manifest['configSHA256'], 'Artwork configuration changed')
    check(sha256(root / 'scripts/store-artwork/render.swift') == manifest['rendererSHA256'],
          'Renderer changed')
    check(config['platform'] == 'mac' and (config['width'], config['height']) == (2560, 1600),
          'Unexpected platform or canvas')
    check(len(config['panels']) == 3, 'Unexpected panel count')
    for relative, expected in manifest['sourceImages'].items():
        path = pack / relative
        check(path.read_bytes()[:3] == b'\xff\xd8\xff', f'Expected JPEG source: {relative}')
        check(sha256(path) == expected['sha256'], f'Source pixels changed: {relative}')
        check(dimensions(path) == (expected['width'], expected['height']),
              f'Source dimensions changed: {relative}')
    for panel in config['panels']:
        details = panel.get('variants', [panel])
        for detail in details:
            check(detail['image'] in manifest['sourceImages'], 'Missing source provenance')
            source = manifest['sourceImages'][detail['image']]
            crop = detail.get('crop', [0, 0, source['width'], source['height']])
            x, y, width, height = crop
            check(x >= 0 and y >= 0 and width > 0 and height > 0 and
                  x + width <= source['width'] and y + height <= source['height'],
                  f'Out-of-bounds crop: {panel["id"]}')
        path = pack / config['output'] / (panel['id'] + '.png')
        data = path.read_bytes()
        check(data[:8] == b'\x89PNG\r\n\x1a\n', f'Invalid PNG: {path.name}')
        width, height, depth, color_type, _, _, _ = struct.unpack('>IIBBBBB', data[16:29])
        check((width, height, depth, color_type) == (2560, 1600, 8, 2),
              f'Expected opaque 8-bit RGB 2560x1600: {path.name}')
        expected = manifest['storeExports'][path.name]
        check(sha256(path) == expected['sha256'], f'Export bytes changed: {path.name}')
        check(len(data) == expected['bytes'], f'Export size changed: {path.name}')
    check(set(p.name for p in (pack / config['output']).glob('*.png')) ==
          set(manifest['storeExports']), 'Unlisted or missing export')
    print('PASS: 3 opaque Mac exports, 5 original JPEG sources, exact hashes, valid crops and renderer/config parity')


if __name__ == '__main__':
    try:
        main()
    except (KeyError, ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f'FAIL: {error}', file=sys.stderr)
        raise SystemExit(1)
