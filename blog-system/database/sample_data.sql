-- 使用数据库
USE blog_system;

-- 插入更多用户数据
INSERT INTO users (username, email, password_hash, role) VALUES 
('writer', 'writer@example.com', '$pbkdf2-sha256$29000$GqRbXl8W3XJZ$yqVJZ9c8x7wPmQ3nR5tK6uL8vB4jH7aD1eF2gA9kE0lU3sZ5dX6c', 'user'),
('reader', 'reader@example.com', '$pbkdf2-sha256$29000$GqRbXl8W3XJZ$yqVJZ9c8x7wPmQ3nR5tK6uL8vB4jH7aD1eF2gA9kE0lU3sZ5dX6c', 'user');

-- 插入更多文章数据
INSERT INTO articles (title, content, author_id, status, category, tags) VALUES 
('Python数据科学入门', 'Python在数据科学领域有着广泛的应用...\n\n## NumPy基础\nNumPy是Python科学计算的基础库...\n\n## Pandas数据处理\nPandas提供了强大的数据结构和数据分析工具...', 1, 'published', '数据科学', '["Python", "数据科学", "NumPy", "Pandas"]'),
('RESTful API设计原则', 'RESTful API是现代Web服务的标准设计风格...\n\n### 资源命名\n使用名词而非动词来命名资源...\n\n### HTTP方法使用\n正确使用GET、POST、PUT、DELETE等HTTP方法...', 1, 'published', 'API设计', '["RESTful", "API", "Web开发"]'),
('前端性能优化技巧', '前端性能对于用户体验至关重要...\n\n#### 代码分割\n使用代码分割减少初始加载时间...\n\n#### 图片优化\n合理压缩和选择图片格式...', 2, 'published', '前端', '["性能优化", "前端开发", "JavaScript"]'),
('Git版本控制最佳实践', 'Git是目前最流行的分布式版本控制系统...\n\n**分支管理**\n- main/master分支保持稳定\n- feature分支用于开发新功能...', 1, 'published', '工具', '["Git", "版本控制", "开发工具"]'),
('Docker容器化应用', 'Docker可以简化应用的部署和运行环境管理...', 2, 'draft', 'DevOps', '["Docker", "容器化", "DevOps"]');

-- 插入更多评论数据
INSERT INTO comments (article_id, user_id, content) VALUES 
(1, 3, '很实用的教程，对初学者帮助很大！'),
(1, 4, '期待更多Flask相关的内容。'),
(2, 3, 'Vue3的组合式API确实很强大。'),
(3, 2, '数据科学是未来的趋势。'),
(4, 1, 'API设计是后端开发的重要部分。'),
(5, 3, '性能优化是一个持续的过程。');

-- 显示插入的示例数据数量
SELECT '用户数据' AS data_type, COUNT(*) AS count FROM users;
SELECT '文章数据' AS data_type, COUNT(*) AS count FROM articles;
SELECT '评论数据' AS data_type, COUNT(*) AS count FROM comments;

-- 显示最新的文章和评论
SELECT a.id, a.title, a.author_id, u.username AS author_name, a.status, a.created_at 
FROM articles a 
JOIN users u ON a.author_id = u.id 
ORDER BY a.created_at DESC 
LIMIT 3;

SELECT c.id, c.article_id, c.user_id, u.username AS commenter, c.content, c.created_at 
FROM comments c 
JOIN users u ON c.user_id = u.id 
ORDER BY c.created_at DESC 
LIMIT 3;