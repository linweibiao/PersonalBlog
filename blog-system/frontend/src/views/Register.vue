<template>
  <div class="register-container">
    <el-card shadow="hover" class="register-card">
      <template #header>
        <div class="card-header">
          <h2>用户注册</h2>
        </div>
      </template>
      <el-form
        :model="registerForm"
        :rules="rules"
        ref="registerFormRef"
        label-width="80px"
        class="register-form"
      >
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="registerForm.username"
            placeholder="请输入用户名"
            prefix-icon="el-icon-user"
            clearable
          />
        </el-form-item>
        
        <el-form-item label="邮箱" prop="email">
          <el-input
            v-model="registerForm.email"
            type="email"
            placeholder="请输入邮箱"
            prefix-icon="el-icon-message"
            clearable
          />
        </el-form-item>
        
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="registerForm.password"
            type="password"
            placeholder="请输入密码"
            prefix-icon="el-icon-lock"
            show-password
          />
        </el-form-item>
        
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            v-model="registerForm.confirmPassword"
            type="password"
            placeholder="请确认密码"
            prefix-icon="el-icon-lock"
            show-password
          />
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="handleRegister" :loading="loading" class="register-button">
            注册
          </el-button>
          <el-link type="primary" href="/login" style="margin-left: 20px;">
            已有账号？去登录
          </el-link>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { userStore } from '../stores/user'

const router = useRouter()
const registerFormRef = ref<FormInstance>()
const loading = ref(false)

const registerForm = reactive({
  username: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const rules = reactive<FormRules>({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度在 3 到 50 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少为 6 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { 
      validator: (_rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      }, 
      trigger: 'blur' 
    }
  ]
})

const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  await registerFormRef.value.validate(async (valid) => {
    if (valid) {
      console.log('提交注册表单:', registerForm)
      loading.value = true
      try {
        // 调试日志，记录发送给后端的注册数据
        console.log('向后端发送注册数据:', { username: registerForm.username, email: registerForm.email });
        
        const result = await userStore().register(
          registerForm.username,
          registerForm.email,
          registerForm.password
        )
        
        // 调试日志，记录后端返回的结果
        console.log('后端注册返回结果:', result);
        if (result.success) {
          ElMessage.success('注册成功，已自动登录')
          router.push('/')
        } else {
          console.log('注册失败，详细信息:', result.message)
          // 根据错误类型显示不同的错误提示
          let errorMsg = result.message || '注册失败，请重试'
          
          // 针对特定错误类型的处理
          if (errorMsg.includes('用户名已存在')) {
            ElMessage.error('该用户名已被注册，请更换用户名')
            // 聚焦到用户名输入框
            const usernameInput = document.querySelector('[name="username"]') as HTMLInputElement
            if (usernameInput) usernameInput.focus()
          } else if (errorMsg.includes('邮箱已存在')) {
            ElMessage.error('该邮箱已被注册，请更换邮箱')
            // 聚焦到邮箱输入框
            const emailInput = document.querySelector('[name="email"]') as HTMLInputElement
            if (emailInput) emailInput.focus()
          } else if (errorMsg.includes('请求数据不完整')) {
            ElMessage.error('请填写完整的注册信息')
          } else {
            ElMessage.error(errorMsg)
          }
        }
      } catch (error: any) {
        console.log('注册异常:', error)
        // 处理网络错误等异常情况
        if (error.message && error.message.includes('Network Error')) {
          ElMessage.error('网络连接失败，请检查网络设置或稍后重试')
        } else {
          ElMessage.error('注册过程中发生未知错误，请稍后重试')
        }
      } finally {
        loading.value = false
      }
    } else {
      console.log('表单验证失败')
    }
  })
}
</script>

<style scoped>
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 500px;
}

.register-card {
  width: 450px;
  border-radius: 8px;
}

.card-header {
  text-align: center;
}

.card-header h2 {
  margin: 0;
  color: #333;
}

.register-form {
  padding: 20px 0;
}

.register-button {
  width: 100%;
}
</style>