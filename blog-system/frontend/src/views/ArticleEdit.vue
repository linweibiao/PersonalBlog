<template>
  <div class="article-edit">
    <div v-if="loading" class="loading">
      <el-skeleton :rows="10" animated />
    </div>
    
    <el-card v-else shadow="hover" class="edit-card">
      <template #header>
        <div class="card-header">
          <h2>{{ isCreating ? '创建文章' : '编辑文章' }}</h2>
        </div>
      </template>
      
      <el-form
        :model="articleForm"
        :rules="rules"
        ref="articleFormRef"
        label-width="80px"
        class="article-form"
      >
        <el-form-item label="标题" prop="title">
          <el-input
            v-model="articleForm.title"
            placeholder="请输入文章标题"
            clearable
            show-word-limit
            maxlength="200"
          />
        </el-form-item>
        
        <el-form-item label="分类" prop="category">
          <el-input
            v-model="articleForm.category"
            placeholder="请输入文章分类"
            clearable
            show-word-limit
            maxlength="50"
          />
        </el-form-item>
        
        <el-form-item label="标签" prop="tags">
          <el-input
            v-model="tagInput"
            placeholder="请输入标签，使用逗号分隔"
            clearable
          />
          <el-button type="primary" size="small" @click="addTag" style="margin-top: 10px;">
            添加标签
          </el-button>
          <div class="tags-container">
            <el-tag
              v-for="(tag, index) in articleForm.tags"
              :key="index"
              closable
              @close="removeTag(index)"
              size="medium"
            >
              {{ tag }}
            </el-tag>
          </div>
        </el-form-item>
        
        <el-form-item label="内容" prop="content">
          <el-input
            v-model="articleForm.content"
            type="textarea"
            placeholder="请输入文章内容（支持Markdown格式）"
            :rows="15"
            resize="vertical"
          />
        </el-form-item>
        
        <el-form-item label="状态">
          <el-radio-group v-model="articleForm.status">
            <el-radio label="published">发布</el-radio>
            <el-radio label="draft">保存为草稿</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="saveArticle" :loading="submitting">
            {{ isCreating ? '创建文章' : '更新文章' }}
          </el-button>
          <el-button @click="cancel">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, getCurrentInstance } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

// 从app实例获取axios
const { proxy } = getCurrentInstance() as any
const axios = proxy.$axios

// 确保axios实例配置正确
console.log('Axios配置:', {
  baseURL: axios.defaults.baseURL,
  interceptors: !!axios.interceptors.request.handlers.length
})

const route = useRoute()
const router = useRouter()
const articleFormRef = ref<FormInstance>()
const loading = ref(true)
const submitting = ref(false)
const tagInput = ref('')
const article = ref<any>(null)

const articleForm = reactive({
  title: '',
  content: '',
  category: '',
  tags: [] as string[],
  status: 'draft'
})

const rules = reactive<FormRules>({
  title: [
    { required: true, message: '请输入文章标题', trigger: 'blur' },
    { min: 1, max: 200, message: '标题长度在 1 到 200 个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入文章内容', trigger: 'blur' }
  ]
})

const articleId = computed(() => route.params.id as string)
const isCreating = computed(() => !articleId.value)

const loadArticle = async () => {
    loading.value = true
    try {
      const response = await axios.get(`/api/articles/${articleId.value}`)
    
    // 确保响应数据存在且格式正确
    if (!response.data || typeof response.data !== 'object') {
      throw new Error('响应数据格式错误')
    }
    
    article.value = response.data
    
    // 填充表单数据
    articleForm.title = article.value.title || ''
    articleForm.content = article.value.content || ''
    articleForm.category = article.value.category || ''
    articleForm.tags = article.value.tags || []
    articleForm.status = article.value.status || 'draft'
  } catch (error) {
    console.error('加载文章失败:', error)
    article.value = null
    ElMessage.error('加载文章失败或无权限访问')
  } finally {
    loading.value = false
  }
}

const addTag = () => {
  const tag = tagInput.value.trim()
  if (tag && !articleForm.tags.includes(tag)) {
    articleForm.tags.push(tag)
    tagInput.value = ''
  }
}

const removeTag = (index: number) => {
  articleForm.tags.splice(index, 1)
}

const cancel = () => {
  router.back()
}

const saveArticle = async () => {
    if (!articleFormRef.value) return
    
    await articleFormRef.value.validate(async (valid) => {
      if (valid) {
        submitting.value = true
        try {
          let response
          if (isCreating.value) {
            // 创建文章
            response = await axios.post('/api/articles/', {
              title: articleForm.title,
              content: articleForm.content,
              category: articleForm.category,
              tags: articleForm.tags,
              status: articleForm.status
            })
            ElMessage.success('文章创建成功')
            // 跳转到文章列表或首页
            router.push('/articles')
          } else {
            // 更新文章
            response = await axios.put(`/api/articles/${articleId.value}/`, {
              title: articleForm.title,
              content: articleForm.content,
              category: articleForm.category,
              tags: articleForm.tags,
              status: articleForm.status
            })
            
            if (response.data) {
              ElMessage.success('文章更新成功')
              router.push(`/article/${articleId.value}`)
            } else {
              ElMessage.error('更新失败，请重试')
            }
          }
        } catch (error: any) {
          const message = error.response?.data?.message || (isCreating.value ? '创建失败，请重试' : '更新失败，请重试')
          ElMessage.error(message)
        } finally {
          submitting.value = false
        }
      }
    })
  }

onMounted(() => {
  if (isCreating.value) {
    // 创建文章，不需要加载文章详情
    loading.value = false
  } else {
    // 编辑文章，加载文章详情
    loadArticle()
  }
})
</script>

<style scoped>
.article-edit {
  padding-bottom: 40px;
}

.loading {
  margin-bottom: 20px;
}

.edit-card {
  border-radius: 8px;
}

.card-header h2 {
  margin: 0;
  color: #333;
}

.article-form {
  padding: 20px 0;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}

:deep(.el-textarea__inner) {
  min-height: 300px;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 14px;
  line-height: 1.8;
}

.article-not-found {
  text-align: center;
  padding: 60px 0;
}

.article-not-found button {
  margin-top: 20px;
}
</style>