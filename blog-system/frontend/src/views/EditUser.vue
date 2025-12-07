<template>
  <div class="edit-user-container">
    <el-card shadow="hover" class="edit-user-card">
      <template #header>
        <div class="card-header">
          <h2>编辑用户信息</h2>
        </div>
      </template>
      
      <el-form
        ref="userFormRef"
        :model="userForm"
        :rules="userFormRules"
        label-position="top"
        label-width="100px"
        status-icon
      >
        <el-form-item label="用户ID" prop="id">
          <el-input v-model="userForm.id" readonly placeholder="用户ID" />
        </el-form-item>
        
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" placeholder="请输入用户名" />
        </el-form-item>
        
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" type="email" placeholder="请输入邮箱" />
        </el-form-item>
        
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role" placeholder="请选择角色">
            <el-option label="普通用户" value="user" />
            <el-option label="管理员" value="admin" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="注册时间" prop="created_at">
          <el-input v-model="userForm.created_at" readonly placeholder="注册时间" />
        </el-form-item>
        
        <el-form-item label="当前密码状态" prop="password_status">
          <el-input v-model="userForm.password_status" readonly placeholder="当前密码状态" />
        </el-form-item>
        
        <el-divider>修改密码（可选）</el-divider>
        
        <el-form-item label="新密码" prop="password">
          <el-input v-model="userForm.password" type="password" placeholder="请输入新密码" show-password />
        </el-form-item>
        
        <el-form-item label="确认新密码" prop="confirm_password">
          <el-input v-model="userForm.confirm_password" type="password" placeholder="请再次输入新密码" show-password />
        </el-form-item>
        
        <el-form-item>
          <div class="form-buttons">
            <el-button type="primary" @click="handleSubmit">保存修改</el-button>
            <el-button @click="handleCancel">取消</el-button>
          </div>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox, FormInstance, FormRules } from 'element-plus'
import { userStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const store = userStore()
const userFormRef = ref<FormInstance>()

// 从路由参数获取用户ID
const userId = computed(() => parseInt(route.params.userId as string) || 0)

// 用户表单数据
const userForm = reactive({
  id: '',
  username: '',
  email: '',
  role: 'user',
  created_at: '',
  password_status: '密码已设置',
  password: '',
  confirm_password: ''
})

// 表单验证规则
const userFormRules = reactive<FormRules>({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度在 3 到 50 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入有效的邮箱地址', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ],
  password: [
    { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: 'blur' }
  ],
  confirm_password: [
    {
      validator: (rule, value, callback) => {
        if (value !== userForm.password) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: ['blur', 'change']
    }
  ]
})

// 加载用户信息
const loadUserInfo = async () => {
  try {
    // 发送API请求，获取用户信息
    const response = await fetch(`http://localhost:5000/api/admin/users/${userId.value}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${store.token}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!response.ok) {
      throw new Error('获取用户信息失败')
    }
    
    const userData = await response.json()
    
    // 格式化日期
    const createdDate = new Date(userData.created_at)
    const formattedDate = createdDate.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
    
    // 更新表单数据
    userForm.id = userData.id
    userForm.username = userData.username
    userForm.email = userData.email
    userForm.role = userData.role
    userForm.created_at = formattedDate
  } catch (error) {
    ElMessage.error('获取用户信息失败，请重试')
    console.error('获取用户信息失败:', error)
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!userFormRef.value) return
  
  try {
    // 验证表单
    await userFormRef.value.validate()
    
    // 显示确认对话框
    await ElMessageBox.confirm(
      '确定要保存对用户的修改吗？',
      '操作确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    // 构建请求体，只包含需要更新的字段
    const requestBody = {
      username: userForm.username,
      email: userForm.email,
      role: userForm.role
    }
    
    // 如果用户输入了密码，则添加到请求体中
    if (userForm.password) {
      requestBody.password = userForm.password
    }
    
    // 发送API请求，更新用户信息
    const response = await fetch(`http://localhost:5000/api/admin/users/${userId.value}`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${store.token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(requestBody)
    })
    
    if (!response.ok) {
      throw new Error('更新用户信息失败')
    }
    
    ElMessage.success('用户信息更新成功')
    
    // 跳回用户管理页面
    router.push('/admin')
  } catch (error: any) {
    if (error === 'cancel') {
      // 用户点击了取消按钮
      ElMessage.info('已取消保存修改')
    } else if (error.name === 'ValidationError') {
      ElMessage.error('表单验证失败，请检查输入')
    } else {
      ElMessage.error('更新用户信息失败，请重试')
    }
    console.error('更新用户信息失败:', error)
  }
}

// 取消操作
const handleCancel = () => {
  // 跳回用户管理页面
  router.push('/admin')
}

// 页面加载时获取用户信息
onMounted(() => {
  // 验证用户是否已登录且为管理员
  if (!store.isLoggedIn || store.user?.role !== 'admin') {
    ElMessage.error('您没有权限访问此页面')
    router.push('/')
    return
  }
  
  // 加载用户信息
  loadUserInfo()
})
</script>

<style scoped>
.edit-user-container {
  max-width: 600px;
  margin: 40px auto;
  padding: 0 20px;
}

.edit-user-card {
  border-radius: 8px;
}

.card-header h2 {
  margin: 0;
  color: #333;
}

.form-buttons {
  display: flex;
  justify-content: flex-start;
  gap: 10px;
  margin-top: 20px;
}
</style>