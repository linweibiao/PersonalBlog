<template>
  <div class="user-profile">
    <el-card shadow="hover" class="profile-card">
      <template #header>
        <h2>个人中心</h2>
      </template>
      
      <!-- 用户基本信息 -->
      <el-tabs v-model="activeTab" class="profile-tabs">
        <!-- 个人资料 -->
        <el-tab-pane label="个人资料" name="profile">
          <div v-if="loading" class="loading">
            <el-skeleton :rows="8" animated />
          </div>
          
          <template v-else>
            <el-form :model="profileForm" :rules="profileRules" ref="profileFormRef" label-width="80px">
              <el-form-item label="用户名" prop="username">
                <el-input v-model="profileForm.username" placeholder="请输入用户名" />
              </el-form-item>
              
              <el-form-item label="邮箱" prop="email">
                <el-input v-model="profileForm.email" placeholder="请输入邮箱" />
              </el-form-item>
              
              <el-form-item label="用户角色">
                <el-input v-model="profileForm.role" disabled />
              </el-form-item>
              
              <el-form-item label="注册时间">
                <el-input v-model="formattedCreatedAt" disabled />
              </el-form-item>
              
              <el-form-item>
                <el-button type="primary" @click="updateProfile" :loading="updating">
                  保存修改
                </el-button>
              </el-form-item>
            </el-form>
          </template>
        </el-tab-pane>
        
        <!-- 我的文章 -->
        <el-tab-pane label="我的文章" name="articles">
          <div class="article-filters">
            <el-radio-group v-model="articleFilter.status" @change="loadArticles">
              <el-radio-button label="">全部</el-radio-button>
              <el-radio-button label="published">已发布</el-radio-button>
              <el-radio-button label="draft">草稿</el-radio-button>
            </el-radio-group>
            
            <el-button type="primary" class="create-btn" @click="$router.push('/article/create')">
              <el-icon><Plus /></el-icon> 写文章
            </el-button>
          </div>
          
          <div v-if="loadingArticles" class="loading">
            <el-skeleton :rows="10" animated />
          </div>
          
          <template v-else-if="articles.length > 0">
            <el-table :data="articles" stripe style="width: 100%" border>
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="title" label="标题" min-width="300">
                <template #default="scope">
                  <el-link type="primary" @click="$router.push(`/article/${scope.row.id}`)">
                    {{ scope.row.title }}
                  </el-link>
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="100">
                <template #default="scope">
                  <el-tag :type="scope.row.status === 'published' ? 'success' : 'warning'">
                    {{ scope.row.status === 'published' ? '已发布' : '草稿' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="category" label="分类" width="120" />
              <el-table-column prop="tags" label="标签" min-width="200">
                <template #default="scope">
                  <el-tag v-for="tag in scope.row.tags" :key="tag" size="small" effect="plain">
                    {{ tag }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="created_at" label="创建时间" width="180" />
              <el-table-column prop="updated_at" label="更新时间" width="180" />
              <el-table-column label="操作" width="150" fixed="right">
                <template #default="scope">
                  <el-button type="primary" size="small" @click="$router.push(`/article/edit/${scope.row.id}`)">
                    <el-icon><Edit /></el-icon> 编辑
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
            
            <div class="pagination">
              <el-pagination
                v-model:current-page="currentPage"
                v-model:page-size="pageSize"
                :page-sizes="[10, 20, 50]"
                layout="total, sizes, prev, pager, next, jumper"
                :total="totalArticles"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
              />
            </div>
          </template>
          
          <template v-else>
            <el-empty description="暂无文章" />
            <el-button type="primary" class="create-btn" @click="$router.push('/article/create')">
              <el-icon><Plus /></el-icon> 写第一篇文章
            </el-button>
          </template>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, getCurrentInstance } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus, Edit } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'

// 从app实例获取axios
const { proxy } = getCurrentInstance() as any
const axios = proxy.$axios
const router = useRouter()

// 加载状态
const loading = ref(false)
const loadingArticles = ref(false)
const updating = ref(false)

// 标签页
const activeTab = ref('profile')

// 个人资料表单
const profileForm = ref({
  username: '',
  email: '',
  role: '',
  created_at: ''
})

const formattedCreatedAt = computed(() => {
  if (!profileForm.value.created_at) return ''
  return new Date(profileForm.value.created_at).toLocaleDateString('zh-CN')
})

// 表单验证规则
const profileRules = ref<FormRules>({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入有效的邮箱地址', trigger: 'blur' }
  ]
})

// 表单引用
const profileFormRef = ref<FormInstance>()

// 文章列表
const articles = ref<any[]>([])
const totalArticles = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

// 文章筛选
const articleFilter = ref({
  status: ''
})

// 获取用户资料
const loadProfile = async () => {
  loading.value = true
  try {
    const response = await axios.get('/api/auth/profile')
    profileForm.value = response.data
  } catch (error) {
    console.error('获取用户资料失败:', error)
    ElMessage.error('获取用户资料失败')
  } finally {
    loading.value = false
  }
}

// 获取用户文章
const loadArticles = async () => {
  loadingArticles.value = true
  try {
    const response = await axios.get('/api/auth/profile/articles', {
      params: {
        page: currentPage.value,
        per_page: pageSize.value,
        status: articleFilter.value.status
      }
    })
    articles.value = response.data.articles
    totalArticles.value = response.data.total
    currentPage.value = response.data.current_page
  } catch (error) {
    console.error('获取用户文章失败:', error)
    ElMessage.error('获取用户文章失败')
  } finally {
    loadingArticles.value = false
  }
}

// 更新个人资料
const updateProfile = async () => {
  if (!profileFormRef.value) return
  
  await profileFormRef.value.validate(async (valid) => {
    if (valid) {
      updating.value = true
      try {
        const response = await axios.put('/api/auth/profile', {
          username: profileForm.value.username,
          email: profileForm.value.email
        })
        ElMessage.success('个人资料更新成功')
      } catch (error) {
        console.error('更新个人资料失败:', error)
        // @ts-ignore
        ElMessage.error(error.response?.data?.message || '更新个人资料失败')
      } finally {
        updating.value = false
      }
    }
  })
}

// 分页处理
const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1
  loadArticles()
}

const handleCurrentChange = (page: number) => {
  currentPage.value = page
  loadArticles()
}

// 初始化
onMounted(() => {
  loadProfile()
  loadArticles()
})
</script>

<style scoped>
.user-profile {
  padding-bottom: 40px;
}

.profile-card {
  border-radius: 8px;
}

.profile-tabs {
  margin-top: 20px;
}

.loading {
  margin-bottom: 20px;
}

.article-filters {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.create-btn {
  margin-left: auto;
}

.pagination {
  margin-top: 20px;
  text-align: right;
}
</style>