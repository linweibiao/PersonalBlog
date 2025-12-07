<template>
  <div class="login-container">
    <el-card shadow="hover" class="login-card">
      <template #header>
        <div class="card-header">
          <h2>用户登录</h2>
        </div>
      </template>
      <el-form
        :model="loginForm"
        :rules="rules"
        ref="loginFormRef"
        label-width="80px"
        class="login-form"
      >
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="请输入用户名"
            prefix-icon="el-icon-user"
            clearable
          />
        </el-form-item>
        
        <el-form-item label="密码" prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            prefix-icon="el-icon-lock"
            show-password
          />
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="handleLogin" :loading="loading" class="login-button">
            登录
          </el-button>
          <el-link type="primary" href="/register" style="margin-left: 20px;">
            立即注册
          </el-link>
        </el-form-item>
        
        <div class="login-tips">
          <p>测试账号：</p>
          <p>管理员：admin / admin123</p>
          <p>普通用户：user / user123</p>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { userStore } from '../stores/user'

const router = useRouter()
const route = useRoute()
const loginFormRef = ref<FormInstance>()
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const rules = reactive<FormRules>({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度在 3 到 50 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少为 6 个字符', trigger: 'blur' }
  ]
})

const handleLogin = async () => {
      if (!loginFormRef.value) return
      
      await loginFormRef.value.validate(async (valid) => {
        if (valid) {
          console.log('提交登录表单:', loginForm)
          loading.value = true
          try {
            const result = await userStore().login(loginForm.username, loginForm.password)
            if (result.success) {
              ElMessage.success('登录成功')
              // 跳转到之前的页面或首页
              const redirect = route.query.redirect as string || '/'  
              router.push(redirect)
            } else {
              console.log('登录失败，详细信息:', result.message)
              ElMessage.error(result.message)
            }
          } catch (error) {
            console.log('登录异常:', error)
            ElMessage.error('登录失败，请重试')
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
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 500px;
}

.login-card {
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

.login-form {
  padding: 20px 0;
}

.login-button {
  width: 100%;
}

.login-tips {
  margin-top: 20px;
  padding: 15px;
  background-color: #f0f9ff;
  border: 1px solid #91d5ff;
  border-radius: 4px;
  color: #666;
}

.login-tips p {
  margin: 5px 0;
  font-size: 14px;
}
</style>