<template>
  <div class="article-list">
    <el-card shadow="hover" class="list-card">
      <template #header>
        <div class="card-header">
          <h2>文章列表</h2>
          <el-select v-model="status" placeholder="文章状态" size="small" @change="loadArticles">
            <el-option label="已发布" value="published"></el-option>
            <el-option label="草稿" value="draft"></el-option>
          </el-select>
        </div>
      </template>
      
      <div class="articles-content">
        <div v-if="loading" class="loading">
          <el-skeleton :rows="5" animated />
        </div>
        
        <template v-else-if="articles.length > 0">
          <el-card v-for="article in articles" :key="article.id" shadow="hover" class="article-card">
            <router-link :to="'/article/' + article.id" class="article-link">
              <h3>{{ article.title }}</h3>
              <div class="article-meta">
                <span>作者：{{ getAuthorName(article.author_id) }}</span>
                <span>分类：{{ article.category || '未分类' }}</span>
                <span>状态：{{ article.status === 'published' ? '已发布' : '草稿' }}</span>
                <span>{{ formatDate(article.created_at) }}</span>
              </div>
              <p class="article-excerpt">{{ getExcerpt(article.content) }}</p>
              <div class="article-tags">
                <el-tag v-for="tag in article.tags" :key="tag" size="small">{{ tag }}</el-tag>
              </div>
            </router-link>
          </el-card>
          
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[5, 10, 20]"
            :total="total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </template>
        
        <template v-else>
          <div class="empty-state">
            <el-empty description="暂无文章"></el-empty>
          </div>
        </template>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, getCurrentInstance } from 'vue'

// 从app实例获取axios
const { proxy } = getCurrentInstance() as any
const axios = proxy.$axios

const articles = ref<any[]>([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const status = ref('published')
const authors = ref<Map<number, string>>(new Map())

const getExcerpt = (content: string) => {
  const text = content.replace(/[\n\r#*`\[\]]/g, ' ')
  return text.length > 200 ? text.substring(0, 200) + '...' : text
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getAuthorName = (authorId: number) => {
  return authors.value.get(authorId) || '未知作者'
}

const loadAuthors = async (authorIds: number[]) => {
    for (const id of authorIds) {
      if (!authors.value.has(id)) {
        try {
          // 在实际项目中，应该有一个获取用户信息的API
          // 这里为了简化，我们假设能通过管理员API获取
          try {
              const userResponse = await axios.get(`/api/admin/users/${id}`)
              authors.value.set(id, userResponse.data.username)
            } catch {
              // 如果获取失败，使用占位符
              authors.value.set(id, `用户${id}`)
            }
        } catch {
          console.error(`获取用户${id}信息失败`)
        }
      }
    }
  }

  const loadArticles = async () => {
    loading.value = true
    try {
      const response = await axios.get('/api/articles', {
        params: {
          page: currentPage.value,
          per_page: pageSize.value,
          status: status.value
        }
      })
    
    // 确保响应数据存在且格式正确
    if (!response.data || typeof response.data !== 'object') {
      throw new Error('响应数据格式错误')
    }
    
    articles.value = response.data.articles || []
    total.value = response.data.total || 0
    
    // 加载作者信息
    const authorIds = [...new Set(articles.value.map(a => a.author_id))]
    await loadAuthors(authorIds)
  } catch (error) {
    console.error('加载文章失败:', error)
    // 清空文章列表，避免显示错误数据
    articles.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleSizeChange = (newSize: number) => {
  pageSize.value = newSize
  currentPage.value = 1
  loadArticles()
}

const handleCurrentChange = (newCurrent: number) => {
  currentPage.value = newCurrent
  loadArticles()
}

onMounted(() => {
  loadArticles()
})
</script>

<style scoped>
.article-list {
  padding-bottom: 40px;
}

.list-card {
  border-radius: 8px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  margin: 0;
  color: #333;
}

.articles-content {
  padding: 20px 0;
}

.loading {
  margin-bottom: 20px;
}

.article-card {
  margin-bottom: 20px;
  transition: transform 0.3s;
}

.article-card:hover {
  transform: translateY(-5px);
}

.article-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.article-link h3 {
  margin-bottom: 10px;
  color: #333;
  font-size: 20px;
}

.article-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 15px;
  font-size: 14px;
  color: #999;
}

.article-excerpt {
  margin-bottom: 15px;
  color: #666;
  line-height: 1.8;
}

.article-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.empty-state {
  padding: 60px 0;
  text-align: center;
}
</style>