<template>
  <el-card :body-style="{ padding: '20px' }" class="article-card">
    <router-link :to="'/article/' + article.id" class="article-link">
      <h3 class="article-title">{{ article.title }}</h3>
      <div class="article-meta">
        <span class="author">{{ authorName }}</span>
        <span class="dot">·</span>
        <span class="date">{{ formatDate(article.created_at) }}</span>
        <span class="dot">·</span>
        <span class="category" v-if="article.category">{{ article.category }}</span>
        <span class="status" v-if="showStatus">
          <el-tag :type="article.status === 'published' ? 'success' : 'info'" size="small">
            {{ article.status === 'published' ? '已发布' : '草稿' }}
          </el-tag>
        </span>
      </div>
      <p class="article-excerpt">{{ getExcerpt(article.content) }}</p>
      <div class="article-tags" v-if="article.tags && article.tags.length > 0">
        <el-tag v-for="tag in article.tags" :key="tag" size="small" type="info" effect="plain">
          {{ tag }}
        </el-tag>
      </div>
    </router-link>
  </el-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Article {
  id: number
  title: string
  content: string
  author_id: number
  status: 'published' | 'draft'
  category?: string
  tags?: string[]
  created_at: string
}

interface Props {
  article: Article
  authorName?: string
  showStatus?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  authorName: '未知作者',
  showStatus: false
})

const getExcerpt = (content: string) => {
  const text = content.replace(/[\n\r#*`\[\]]/g, ' ')
  return text.length > 150 ? text.substring(0, 150) + '...' : text
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}
</script>

<style scoped>
.article-card {
  transition: transform 0.3s, box-shadow 0.3s;
  border-radius: 8px;
}

.article-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 20px rgba(0, 0, 0, 0.1);
}

.article-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.article-title {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 18px;
  font-weight: 500;
  transition: color 0.3s;
}

.article-link:hover .article-title {
  color: #409eff;
}

.article-meta {
  display: flex;
  align-items: center;
  font-size: 13px;
  color: #909399;
  margin-bottom: 12px;
}

.dot {
  margin: 0 8px;
}

.article-excerpt {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 12px;
  font-size: 14px;
}

.article-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.status {
  margin-left: auto;
}
</style>