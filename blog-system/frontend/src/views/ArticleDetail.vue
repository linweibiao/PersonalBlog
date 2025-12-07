<template>
  <div class="article-detail">
    <div v-if="loading" class="loading">
      <el-skeleton :rows="8" animated />
    </div>
    
    <template v-else-if="article">
      <el-card shadow="hover" class="article-card">
        <div class="article-header">
          <h1>{{ article.title }}</h1>
          <div class="article-meta">
            <span>作者：{{ authorName }}</span>
            <span>分类：{{ article.category || '未分类' }}</span>
            <span>{{ formatDate(article.created_at) }}</span>
          </div>
          <div class="article-tags">
            <el-tag v-for="tag in article.tags" :key="tag" size="medium">{{ tag }}</el-tag>
          </div>
          
          <!-- 编辑/删除按钮 -->
          <div class="article-actions" v-if="canEdit">
            <el-button type="primary" size="small" @click="editArticle">
              <el-icon><Edit /></el-icon> 编辑
            </el-button>
            <el-button type="danger" size="small" @click="deleteArticle">
              <el-icon><Delete /></el-icon> 删除
            </el-button>
          </div>
        </div>
        
        <div class="article-content">
          <div v-html="parseContent(article.content)"></div>
        </div>
      </el-card>
      
      <!-- 评论区 -->
      <el-card shadow="hover" class="comments-card">
        <template #header>
          <div class="card-header">
            <h3>评论 ({{ comments.length }})</h3>
          </div>
        </template>
        
        <!-- 添加评论 -->
        <div v-if="isLoggedIn" class="add-comment">
          <el-form :model="commentForm" :rules="commentRules" ref="commentFormRef">
            <el-form-item prop="content">
              <el-input
                v-model="commentForm.content"
                type="textarea"
                placeholder="写下你的评论..."
                :rows="3"
                resize="vertical"
              ></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="submitComment" :loading="submittingComment">
                发表评论
              </el-button>
            </el-form-item>
          </el-form>
        </div>
        
        <div v-else class="login-prompt">
          <el-link type="primary" href="/login">请登录后发表评论</el-link>
        </div>
        
        <!-- 评论列表 -->
        <div class="comments-list">
          <div v-if="loadingComments" class="loading-comments">
            <el-skeleton :rows="3" animated />
          </div>
          
          <template v-else-if="comments.length > 0">
            <el-divider v-for="comment in comments" :key="comment.id">
              <template #left>
                <span class="comment-author">{{ getCommentAuthor(comment.user_id) }}</span>
                <span class="comment-time">{{ formatDate(comment.created_at) }}</span>
              </template>
            </el-divider>
            <div v-for="comment in comments" :key="comment.id" class="comment-item">
              <div class="comment-content">{{ comment.content }}</div>
              <div v-if="canDeleteComment(comment)" class="comment-actions">
                <el-button type="text" size="small" @click="deleteComment(comment.id)" danger>
                  删除
                </el-button>
              </div>
            </div>
          </template>
          
          <template v-else>
            <div class="no-comments">
              <el-empty description="暂无评论，快来发表第一条评论吧"></el-empty>
            </div>
          </template>
        </div>
      </el-card>
    </template>
    
    <template v-else>
      <div class="article-not-found">
        <el-empty description="文章不存在"></el-empty>
        <el-button type="primary" @click="router.push('/')">返回首页</el-button>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, getCurrentInstance } from 'vue'
import { useRoute, useRouter } from 'vue-router'
// 从app实例获取axios
const { proxy } = getCurrentInstance() as any
const axios = proxy.$axios
import { ElMessage, ElMessageBox } from 'element-plus'
import { Edit, Delete } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'
import { userStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const store = userStore()

const article = ref<any>(null)
const loading = ref(false)
const authorName = ref('未知作者')
const comments = ref<any[]>([])
const loadingComments = ref(false)
const commentFormRef = ref<FormInstance>()
const submittingComment = ref(false)
const commentForm = ref({
  content: ''
})
const commentRules = ref<FormRules>({
  content: [
    { required: true, message: '请输入评论内容', trigger: 'blur' },
    { min: 1, max: 500, message: '评论内容长度在 1 到 500 个字符', trigger: 'blur' }
  ]
})
const commentAuthors = ref<Map<number, string>>(new Map())

const articleId = computed(() => route.params.id as string)
const isLoggedIn = computed(() => store.isLoggedIn)
const currentUserId = computed(() => store.user?.id)
const isAdmin = computed(() => store.user?.role === 'admin')

// 判断当前用户是否可以编辑文章
const canEdit = computed(() => {
  if (!article.value) return false
  return store.isLoggedIn && (store.user?.role === 'admin' || store.user?.id === article.value.author_id)
})

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

const parseContent = (content: string) => {
  // 简单的Markdown渲染，实际项目中可以使用专门的Markdown库
  let html = content
    .replace(/^# (.*$)/gm, '<h1>$1</h1>')
    .replace(/^## (.*$)/gm, '<h2>$1</h2>')
    .replace(/^### (.*$)/gm, '<h3>$1</h3>')
    .replace(/\n/g, '<br>')
    .replace(/\*(.*?)\*/gm, '<em>$1</em>')
    .replace(/\*(.*?)\*/gm, '<strong>$1</strong>')
    .replace(/`(.*?)`/gm, '<code>$1</code>')
    .replace(/```([\s\S]*?)```/gm, '<pre><code>$1</code></pre>')
  return html
}

const loadAuthorInfo = async (authorId: number) => {
    try {
      try {
        const response = await axios.get(`/api/admin/users/${authorId}`)
        authorName.value = response.data.username
      } catch {
        // 如果管理员API不可用，使用占位符
        authorName.value = `用户${authorId}`
      }
    } catch (error) {
      console.error('获取作者信息失败:', error)
    }
  }

  const loadArticle = async () => {
    loading.value = true
    try {
      const response = await axios.get(`/api/articles/${articleId.value}`)
      article.value = response.data
      await loadAuthorInfo(article.value.author_id)
    } catch (error) {
      console.error('加载文章失败:', error)
      article.value = null
    } finally {
      loading.value = false
    }
  }

  const getCommentAuthor = (userId: number) => {
    return commentAuthors.value.get(userId) || `用户${userId}`
  }

  const loadComments = async () => {
    loadingComments.value = true
    try {
      console.log('开始加载评论，文章ID:', articleId.value)
      const response = await axios.get(`/api/comments?article_id=${articleId.value}`)
      console.log('评论加载成功，数据:', response.data)
      comments.value = response.data.comments
      
      // 加载评论作者信息
      const userIds = [...new Set(comments.value.map(c => c.user_id))]
      for (const id of userIds) {
        if (!commentAuthors.value.has(id)) {
          try {
            try {
              const userResponse = await axios.get(`/api/auth/users/${id}`)
              commentAuthors.value.set(id, userResponse.data.username)
            } catch {
              commentAuthors.value.set(id, `用户${id}`)
            }
          } catch {
            console.error(`获取评论用户${id}信息失败`)
          }
        }
      }
    } catch (error) {
      console.error('加载评论失败:', error)
      console.error('错误详情:', error.response ? error.response.data : '无响应数据')
    } finally {
      loadingComments.value = false
    }
  }

  const canDeleteComment = (comment: any) => {
    return isAdmin.value || currentUserId.value === comment.user_id || currentUserId.value === article.value.author_id
  }

  const submitComment = async () => {
    if (!commentFormRef.value) return
    
    await commentFormRef.value.validate(async (valid) => {
      if (valid) {
        submittingComment.value = true
        try {
          await axios.post(`/api/comments`, {
            article_id: articleId.value,
            content: commentForm.value.content
          })
          ElMessage.success('评论发表成功')
          commentForm.value.content = ''
          await loadComments()
        } catch (error) {
          ElMessage.error('评论发表失败，请重试')
        } finally {
          submittingComment.value = false
        }
      }
    })
  }

  const deleteComment = async (commentId: number) => {
    try {
      await ElMessageBox.confirm('确定要删除这条评论吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      
      await axios.delete(`/api/comments/${commentId}`)
      ElMessage.success('评论已删除')
      await loadComments()
    } catch (error) {
      // 如果是用户取消，不显示错误消息
      if (error !== 'cancel') {
        ElMessage.error('删除评论失败，请重试')
      }
    }
  }

  const editArticle = () => {
    router.push(`/article/edit/${articleId.value}`)
  }

  const deleteArticle = async () => {
    try {
      await ElMessageBox.confirm('确定要删除这篇文章吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      
      await axios.delete(`/api/articles/${articleId.value}`)
      ElMessage.success('文章已删除')
      router.push('/articles')
    } catch (error) {
      // 如果是用户取消，不显示错误消息
      if (error !== 'cancel') {
        ElMessage.error('删除文章失败，请重试')
      }
    }
  }

onMounted(() => {
  loadArticle()
  loadComments()
})
</script>

<style scoped>
.article-detail {
  padding-bottom: 40px;
}

.loading {
  margin-bottom: 20px;
}

.article-card {
  margin-bottom: 30px;
  border-radius: 8px;
}

.article-header h1 {
  font-size: 28px;
  margin-bottom: 20px;
  color: #333;
}

.article-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 15px;
  font-size: 14px;
  color: #999;
}

.article-tags {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.article-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.article-content {
  padding: 20px 0;
  font-size: 16px;
  line-height: 1.8;
  color: #444;
}

.article-content h1, 
.article-content h2, 
.article-content h3 {
  margin: 20px 0 10px;
}

.article-content p {
  margin-bottom: 15px;
}

.article-content pre {
  background: #f5f5f5;
  padding: 15px;
  border-radius: 4px;
  overflow-x: auto;
  margin: 15px 0;
}

.comments-card {
  border-radius: 8px;
}

.card-header h3 {
  margin: 0;
  color: #333;
}

.add-comment {
  margin-bottom: 30px;
}

.login-prompt {
  text-align: center;
  padding: 20px 0;
  margin-bottom: 30px;
}

.comment-item {
  margin-bottom: 20px;
  padding: 10px 0;
}

.comment-content {
  margin-bottom: 10px;
  line-height: 1.6;
  color: #444;
}

.comment-actions {
  display: flex;
  justify-content: flex-end;
}

.comment-author {
  font-weight: bold;
  margin-right: 15px;
  color: #333;
}

.comment-time {
  color: #999;
  font-size: 14px;
}

.loading-comments {
  margin-bottom: 20px;
}

.no-comments {
  padding: 40px 0;
  text-align: center;
}

.article-not-found {
  text-align: center;
  padding: 60px 0;
}

.article-not-found button {
  margin-top: 20px;
}
</style>