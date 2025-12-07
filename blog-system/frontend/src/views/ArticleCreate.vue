<template>
  <div class="article-create">
    <el-card shadow="hover" class="create-card">
      <template #header>
        <div class="card-header">
          <h2>创建文章</h2>
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
            rows="15"
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
          <el-button type="primary" @click="submitArticle" :loading="submitting">
            {{ articleForm.status === 'published' ? '发布文章' : '保存草稿' }}
          </el-button>
          <el-button @click="resetForm">重置</el-button>
          <el-button @click="cancel">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const router = useRouter()
const articleFormRef = ref<FormInstance>()
const submitting = ref(false)
const tagInput = ref('')

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

const resetForm = () => {
  if (articleFormRef.value) {
    articleFormRef.value.resetFields()
    articleForm.tags = []
  }
}

const cancel = () => {
  router.back()
}

const submitArticle = async () => {
  if (!articleFormRef.value) return
  
  await articleFormRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        const response = await axios.post('/articles', {
          title: articleForm.title,
          content: articleForm.content,
          category: articleForm.category,
          tags: articleForm.tags,
          status: articleForm.status
        })
        
        if (response.data) {
          ElMessage.success(articleForm.status === 'published' ? '文章发布成功' : '草稿保存成功')
          router.push(`/article/${response.data.id}`)
        } else {
          ElMessage.error('操作失败，请重试')
        }
      } catch (error: any) {
        const message = error.response?.data?.message || '操作失败，请重试'
        ElMessage.error(message)
      } finally {
        submitting.value = false
      }
    }
  })
}
</script>

<style scoped>
.article-create {
  padding-bottom: 40px;
}

.create-card {
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
</style>