import requests

# 测试OPTIONS请求
url = 'http://localhost:5000/api/comments?article_id=1'

print("发送OPTIONS请求到:", url)
print("=" * 50)

# 发送OPTIONS请求
try:
    response = requests.options(url, headers={
        'Origin': 'http://localhost:3000',
        'Access-Control-Request-Method': 'GET',
        'Access-Control-Request-Headers': 'Content-Type, Authorization'
    })
    
    print(f"状态码: {response.status_code}")
    print(f"响应头:")
    for key, value in response.headers.items():
        print(f"  {key}: {value}")
    
    print(f"\n响应内容: {response.text}")
    
except Exception as e:
    print(f"请求失败: {str(e)}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 50)
print("测试GET请求:")

# 测试GET请求
try:
    response = requests.get(url)
    
    print(f"状态码: {response.status_code}")
    print(f"响应头:")
    for key, value in response.headers.items():
        print(f"  {key}: {value}")
    
    print(f"\n响应内容: {response.text}")
    
except Exception as e:
    print(f"请求失败: {str(e)}")
    import traceback
    traceback.print_exc()