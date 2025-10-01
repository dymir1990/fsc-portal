#!/usr/bin/env python3
"""Tiny test harness to POST a sample CSV to the backend import endpoint.

Usage:
  TEST_USER_JWT=<jwt> BACKEND_URL=http://localhost:8001 python3 scripts/test_import.py

Notes:
- Requires a valid Supabase user JWT in TEST_USER_JWT environment variable.
- Uses `backend/sample_data/simplepractice_mock.csv` from the repo.
"""
import os
import sys
import requests

BACKEND = os.getenv('BACKEND_URL', 'http://localhost:8001')
TOKEN = os.getenv('TEST_USER_JWT')

if not TOKEN:
    print('ERROR: set TEST_USER_JWT env var to a valid user access token')
    sys.exit(2)

csv_path = os.path.join(os.path.dirname(__file__), '..', 'backend', 'sample_data', 'simplepractice_mock.csv')
if not os.path.exists(csv_path):
    print('ERROR: sample CSV not found at', csv_path)
    sys.exit(2)

url = f"{BACKEND.rstrip('/')}/api/imports/simplepractice"
print('POST', url)
with open(csv_path, 'rb') as fh:
    files = {'file': ('simplepractice_mock.csv', fh, 'text/csv')}
    headers = {'Authorization': f'Bearer {TOKEN}'}
    r = requests.post(url, files=files, headers=headers)
    print('Status:', r.status_code)
    try:
        print(r.json())
    except Exception:
        print(r.text)

