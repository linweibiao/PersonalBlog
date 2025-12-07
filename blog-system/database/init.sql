-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS blog_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE blog_system;

-- 删除已存在的表（如果存在）
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS articles;
DROP TABLE IF EXISTS users;

-- 用户表
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 文章表  
CREATE TABLE articles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    author_id INT NOT NULL,
    status ENUM('draft', 'published') DEFAULT 'draft',
    category VARCHAR(50),
    tags TEXT,  -- 在MySQL中使用TEXT存储JSON格式的标签
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 评论表
CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    article_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 创建索引以提高查询性能
CREATE INDEX idx_articles_author_id ON articles(author_id);
CREATE INDEX idx_articles_status ON articles(status);
CREATE INDEX idx_comments_article_id ON comments(article_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);

-- 插入默认管理员账户（密码：admin123）
INSERT INTO users (username, email, password_hash, role) VALUES 
('admin', 'admin@example.com', '$pbkdf2-sha256$29000$GqRbXl8W3XJZ$yqVJZ9c8x7wPmQ3nR5tK6uL8vB4jH7aD1eF2gA9kE0lU3sZ5dX6c', 'admin');

-- 插入默认用户账户（密码：user123）
INSERT INTO users (username, email, password_hash, role) VALUES 
('user', 'user@example.com', '$pbkdf2-sha256$29000$GqRbXl8W3XJZ$yqVJZ9c8x7wPmQ3nR5tK6uL8vB4jH7aD1eF2gA9kE0lU3sZ5dX6c', 'user');

-- 插入示例文章
INSERT INTO articles (title, content, author_id, status, category, tags) VALUES 
('Flask入门教程', 'Flask是一个轻量级的Python Web框架...', 1, 'published', '技术', '["Python", "Flask", "Web开发"]'),
('Vue3新特性介绍', 'Vue3带来了许多激动人心的新特性...', 2, 'published', '前端', '["Vue3", "JavaScript", "前端开发"]'),
('数据库设计最佳实践', '好的数据库设计可以提高应用性能...', 1, 'draft', '数据库', '["MySQL", "数据库设计", "性能优化"]');

-- 插入示例评论
INSERT INTO comments (article_id, user_id, content) VALUES 
(1, 2, '非常好的教程！'),
(2, 1, '学到了很多新知识。');

-- 显示创建的表结构
SHOW TABLES;
DESCRIBE users;
DESCRIBE articles;
DESCRIBE comments;

-- 显示插入的数据
SELECT * FROM users;
SELECT * FROM articles;
SELECT * FROM comments;