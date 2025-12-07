# 个人博客系统

## 项目简介

这是一个基于Flask和Vue3开发的现代化个人博客系统，支持用户认证、文章发布、评论管理、管理员后台等功能。系统采用前后端分离架构，具有良好的扩展性和可维护性。

## 项目规划

### 项目概述
本项目是一个基于前后端分离架构的个人博客系统，使用Flask作为后端框架，Vue 3 + TypeScript作为前端框架。

### 主要功能模块
1. 用户认证与授权
2. 博客文章管理
3. 用户管理（管理员功能）
4. 评论系统
5. 个人信息管理

## 技术栈

### 后端技术栈
| 技术 | 版本 | 用途 |
|------|------|------|
| Flask | 2.0+ | Web框架 |
| SQLAlchemy | 2.0+ | ORM框架 |
| Flask-JWT-Extended | 4.4.4 | JWT认证 |
| Flask-CORS | 4.0.0 | 跨域资源共享 |
| SQLite | 3.30+ | 可选数据库 |
| MySQL | 5.7+ | 默认数据库 |

### 前端技术栈
| 技术 | 版本 | 用途 |
|------|------|------|
| Vue | 3.0+ | 前端框架 |
| TypeScript | 4.5+ | 类型系统 |
| Element Plus | 2.0+ | UI组件库 |
| Pinia | 2.0+ | 状态管理 |
| Vue Router | 4.0+ | 路由管理 |
| Axios | 1.0+ | HTTP客户端 |
| Vite | 4.5+ | 构建工具 |

## 系统要求

- Python 3.8+（推荐3.10+）
- Node.js 16+（推荐18+）
- npm 8+ 或 yarn 1.22+
- Git

## 安装步骤

### 1. 克隆项目

```bash
# 克隆仓库
git clone [repository-url]

# 进入项目目录
cd PersonalBlog
```

### 2. 后端安装

```bash
# 进入后端目录
cd blog-system/backend

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 3. 前端安装

```bash
# 进入前端目录
cd ../frontend

# 安装依赖（推荐使用npm）
npm install
# 或使用yarn
yarn install
```

## 运行项目

### 方式1：使用启动脚本（推荐）

项目根目录提供了多个启动脚本，适用于不同场景：

#### Windows系统

```powershell
# 启动所有服务（推荐）
.\start_all.ps1

# 后台启动所有服务
.\start_all.ps1 -NoWait

# 简化版启动脚本
.\start_simple.ps1

# 使用批处理脚本启动
.\start_all.bat

# 停止所有服务
.\stop_all.ps1
```

#### Linux/Mac系统

```bash
# 直接运行Python脚本
python3 blog-system/backend/run.py

# 前端开发模式
cd blog-system/frontend && npm run dev
```

### 方式2：手动运行

#### 运行后端服务

```bash
cd blog-system/backend
python run.py
```

后端服务默认运行在：`http://localhost:5000`

#### 运行前端开发服务器

```bash
cd blog-system/frontend
npm run dev
```

前端开发服务器默认运行在：`http://localhost:3000`

#### 运行前端生产服务器

```bash
# 构建前端项目
cd blog-system/frontend
npm run build

# 启动生产服务器
cd dist
python run_server.py
```

前端生产服务器默认运行在：`http://localhost:8000`

## 项目结构

```
blog-system/
├── backend/             # 后端应用目录
│   ├── app/             # 应用核心代码
│   │   ├── routes/      # API路由模块
│   │   │   ├── admin.py      # 管理员API（用户/文章管理）
│   │   │   ├── articles.py    # 文章API（增删改查）
│   │   │   ├── auth.py        # 认证API（登录/注册）
│   │   │   └── comments.py    # 评论API（文章评论）
│   │   ├── utils/       # 工具函数
│   │   │   └── auth.py        # 认证工具（密码哈希/JWT）
│   │   ├── __init__.py  # 应用初始化（创建Flask实例）
│   │   ├── config.py    # 配置文件（数据库/JWT配置）
│   │   └── models.py    # 数据模型（User/Article/Comment）
│   ├── instance/        # 实例目录（SQLite数据库文件）
│   ├── requirements.txt # Python依赖列表
│   └── run.py           # 后端启动脚本
├── database/            # 数据库相关文件
│   ├── init.sql         # 数据库初始化脚本
│   └── sample_data.sql  # 示例数据（可选）
└── frontend/            # 前端应用目录
    ├── dist/            # 构建输出目录
    │   └── run_server.py    # 前端生产服务器
    ├── src/             # 源代码目录
    │   ├── components/  # Vue组件
    │   ├── router/      # 路由配置
    │   ├── stores/      # Pinia状态管理
    │   ├── views/       # 页面视图
    │   ├── App.vue      # 根组件
    │   └── main.ts      # 入口文件
    ├── public/          # 静态资源目录
    ├── package.json     # 项目配置
    ├── tsconfig.json    # TypeScript配置
    └── vite.config.ts   # Vite构建配置
```

## 主要功能

### 用户管理
- ✅ 用户注册、登录、登出
- ✅ 个人信息查看与编辑
- ✅ 密码修改
- ✅ 角色管理（管理员/普通用户）

### 文章管理
- ✅ 文章创建、编辑、删除
- ✅ 文章列表与详情查看
- ✅ 草稿管理
- ✅ 文章分类与标签
- ✅ 按分类/标签筛选

### 评论系统
- ✅ 文章评论
- ✅ 评论列表查看

### 管理员功能
- ✅ 用户列表与管理
- ✅ 用户角色编辑
- ✅ 文章管理
- ✅ 系统统计信息

## 实施方案

### API设计

本项目采用RESTful API设计风格，主要API端点包括：

#### 用户管理API（管理员专用）
- GET /api/admin/users - 获取用户列表
- GET /api/admin/users/{userId} - 获取单个用户信息
- PUT /api/admin/users/{userId} - 更新用户信息
- DELETE /api/admin/users/{userId} - 删除用户

#### 用户认证API
- POST /api/auth/register - 用户注册
- POST /api/auth/login - 用户登录
- GET /api/auth/user - 获取当前用户信息

### 数据库设计
主要表结构包括：
- users - 用户表
- articles - 文章表
- comments - 评论表

## API文档

后端运行后，可通过以下方式访问API接口：

- API根路径：`http://localhost:5000/api`
- 文章列表：`http://localhost:5000/api/articles`
- 用户登录：`http://localhost:5000/api/auth/login`

## API变更记录

### v1.1 版本（当前版本）

#### 变更内容
1. **编辑用户API方法变更**
   - 旧版本：GET /api/admin/users/{userId}
   - 新版本：PUT /api/admin/users/{userId}
   - 说明：将更新用户信息的API从GET方法改为PUT方法，符合RESTful设计规范

2. **请求体格式**
   - 新版本要求使用JSON格式的请求体，包含以下字段：
     - username: 用户名
     - email: 邮箱
     - role: 角色（user/admin）

3. **响应格式**
   - 成功响应：{
       "message": "用户信息更新成功",
       "user": { /* 更新后的用户信息 */ }
     }
   - 错误响应：{
       "error": "错误信息"
     }

### 新功能实现

1. **操作确认对话框**
   - 位置：编辑用户页面
   - 功能：在用户点击"保存修改"按钮时，显示确认对话框，避免误操作
   - 实现方式：使用Element Plus的ElMessageBox组件

## 默认账号

### 管理员账号
- **用户名**：admin
- **密码**：admin123
- **权限**：所有功能

### 测试用户账号
- **用户名**：testuser
- **密码**：newpassword123
- **权限**：普通用户权限

## 开发指南

### 代码规范

#### 后端（Python）
- 遵循PEP 8代码规范
- 使用类型注解
- 函数添加文档字符串
- 模块化设计，避免代码冗余

#### 前端（Vue/TypeScript）
- 遵循Vue 3最佳实践
- 使用Composition API
- 组件命名采用PascalCase
- 代码风格统一，使用ESLint+Prettier

### 开发流程

1. 创建特性分支：`git checkout -b feature/your-feature`
2. 编写代码，添加测试
3. 运行测试：`pytest`（后端）/ `npm run test`（前端）
4. 提交代码：`git commit -m "feat: add your feature"`
5. 推送分支：`git push origin feature/your-feature`
6. 创建Pull Request

### 提交规范
- 每个功能模块完成后进行提交
- 提交信息清晰明了，包含功能描述

### 测试规范
- 每个API端点都需要编写测试用例
- 确保代码质量和功能正确性

## 进度记录

### 已完成的功能
1. **后端API修改**
   - 修改了编辑用户API，将HTTP方法从GET改为PUT
   - 实现了完整的RESTful API接口
   - 确保了数据的正确传输和处理

2. **前端API调用更新**
   - 更新了用户编辑页面的API调用方式，使用PUT请求
   - 确保了前端与后端的正确交互

3. **用户列表页面优化**
   - 优化了用户列表页面的导航体验
   - 确保了用户操作的流畅性

4. **测试编辑用户功能**
   - 创建了测试脚本，验证了API的正确性
   - 确保了前后端功能的正常工作

5. **添加确认对话框**
   - 在编辑用户页面添加了操作确认对话框
   - 避免了误操作的发生

### 正在进行的工作
- 更新项目文档（已完成）

### 待完成的工作
- 无

## 部署说明

### 开发环境

- 后端：Flask开发服务器
- 前端：Vite开发服务器
- 数据库：SQLite

### 生产环境建议

1. **后端部署**：
   - 使用Gunicorn或uWSGI作为WSGI服务器
   - 配置Nginx作为反向代理
   - 设置环境变量管理敏感信息
   - 启用HTTPS

2. **前端部署**：
   - 使用Nginx或Apache托管静态文件
   - 启用CDN加速
   - 配置缓存策略

3. **数据库**：
   - 使用MySQL或PostgreSQL替代SQLite
   - 配置定期备份
   - 优化数据库连接池

4. **安全配置**：
   - 设置强密码策略
   - 启用CSRF保护
   - 配置CORS白名单
   - 定期更新依赖

## 注意事项

1. 管理员API需要管理员权限才能访问
2. 敏感操作需要进行确认，避免误操作
3. 定期备份数据库，确保数据安全
4. 遵循RESTful API设计规范，保持API的一致性

## 常见问题

### 1. 端口被占用

```powershell
# 查找占用端口的进程
netstat -ano | findstr :5000

# 终止进程
taskkill /PID [进程ID] /F
```

### 2. 依赖安装失败

```bash
# 升级pip
pip install --upgrade pip

# 清理npm缓存
npm cache clean --force

# 使用镜像源
npm install --registry=https://registry.npmmirror.com
```

### 3. 数据库连接失败

- 检查数据库配置是否正确
- 确保数据库服务正在运行
- 检查数据库用户权限

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

### v1.0.0（初始版本）
- ✅ 完成前后端基础架构
- ✅ 实现用户认证系统
- ✅ 实现文章管理功能
- ✅ 实现评论系统
- ✅ 实现管理员后台
- ✅ 添加启动脚本

---
**文档更新时间**：2025-12-07
**版本**：v1.0.0
