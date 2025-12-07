import requests

# 测试OPTIONS请求
print('Testing OPTIONS request...')
try:
    response = requests.options('http://localhost:5000/api/comments?article_id=1', headers={'Origin': 'http://localhost:3000'})
    print(f'Status: {response.status_code}')
    print(f'Headers: {dict(response.headers)}')
    print(f'Content: {response.text}')
except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()

# 测试GET请求
print('\nTesting GET request...')
try:
    response = requests.get('http://localhost:5000/api/comments?article_id=1', headers={'Origin': 'http://localhost:3000'})
    print(f'Status: {response.status_code}')
    print(f'Headers: {dict(response.headers)}')
    print(f'Content: {response.text}')
except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()