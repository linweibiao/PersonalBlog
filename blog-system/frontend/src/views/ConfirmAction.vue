<template>
  <div class="confirm-action-container">
    <el-card shadow="hover" class="confirm-card">
      <template #header>
        <div class="card-header">
          <h2>{{ title }}</h2>
        </div>
      </template>
      
      <div class="confirm-content">
        <el-alert
          :title="message"
          :type="alertType"
          description="此操作不可撤销，请谨慎操作。"
          show-icon
          :closable="false"
        />
        
        <div class="action-info" v-if="actionType === 'edit-role'">
          <p>用户名：{{ userInfo.username }}</p>
          <p>当前角色：{{ userInfo.currentRole }}</p>
          <p>新角色：{{ userInfo.newRole }}</p>
        </div>
        
        <div class="action-info" v-else-if="actionType === 'delete-user'">
          <p>用户ID：{{ userInfo.userId }}</p>
          <p>用户名：{{ userInfo.username }}</p>
        </div>
        
        <div class="action-info" v-else-if="actionType === 'delete-article'">
          <p>文章ID：{{ articleInfo.articleId }}</p>
          <p>文章标题：{{ articleInfo.title }}</p>
        </div>
        
        <div class="confirm-buttons">
          <el-button type="primary" @click="handleConfirm">确定</el-button>
          <el-button @click="handleCancel">取消</el-button>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { userStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const store = userStore()

// 从路由参数获取操作类型和相关数据
const actionType = computed(() => route.params.actionType as string)
const userId = computed(() => parseInt(route.query.userId as string) || 0)
const username = computed(() => route.query.username as string || '')
const currentRole = computed(() => route.query.currentRole as string || '')
const newRole = computed(() => route.query.newRole as string || '')
const articleId = computed(() => parseInt(route.query.articleId as string) || 0)
const articleTitle = computed(() => route.query.title as string || '')

// 页面标题
const title = computed(() => {
  if (actionType.value === 'edit-role') {
    return '编辑用户角色确认'
  } else if (actionType.value === 'delete-user') {
    return '删除用户确认'
  } else if (actionType.value === 'delete-article') {
    return '删除文章确认'
  }
  return '操作确认'
})

// 提示消息
const message = computed(() => {
  if (actionType.value === 'edit-role') {
    return `确定要将用户 ${username.value} 的角色从 ${currentRole.value} 更改为 ${newRole.value} 吗？`
  } else if (actionType.value === 'delete-user') {
    return `确定要删除用户 ${username.value} 吗？`
  } else if (actionType.value === 'delete-article') {
    return `确定要删除文章 ${articleTitle.value} 吗？`
  }
  return '确定要执行此操作吗？'
})

// 提示类型
const alertType = computed(() => {
  if (actionType.value === 'edit-role') {
    return 'warning'
  } else if (actionType.value === 'delete-user' || actionType.value === 'delete-article') {
    return 'error'
  }
  return 'info'
})

// 用户信息
const userInfo = computed(() => {
  return {
    userId: userId.value,
    username: username.value,
    currentRole: currentRole.value === 'admin' ? '管理员' : '普通用户',
    newRole: newRole.value === 'admin' ? '管理员' : '普通用户'
  }
})

// 文章信息
const articleInfo = computed(() => {
  return {
    articleId: articleId.value,
    title: articleTitle.value
  }
})

// 处理确定操作
const handleConfirm = async () => {
  try {
    // 根据操作类型执行不同的API调用
    if (actionType.value === 'edit-role') {
      // 编辑用户角色
      await store.updateUserRole(userId.value, newRole.value)
      ElMessage.success('角色更新成功')
    } else if (actionType.value === 'delete-user') {
      // 删除用户
      await store.deleteUser(userId.value)
      ElMessage.success('用户已删除')
    } else if (actionType.value === 'delete-article') {
      // 删除文章
      await store.deleteArticle(articleId.value)
      ElMessage.success('文章已删除')
    }
    
    // 操作成功后，返回上一页
    router.back()
  } catch (error) {
    ElMessage.error('操作失败，请重试')
  }
}

// 处理取消操作
const handleCancel = () => {
  // 直接返回上一页，不执行任何操作
  router.back()
}

// 页面加载时验证权限
onMounted(() => {
  // 验证用户是否已登录且为管理员
  if (!store.isLoggedIn || store.user?.role !== 'admin') {
    ElMessage.error('您没有权限访问此页面')
    router.push('/')
  }
})
</script>

<style scoped>
.confirm-action-container {
  max-width: 600px;
  margin: 40px auto;
  padding: 0 20px;
}

.confirm-card {
  border-radius: 8px;
}

.card-header h2 {
  margin: 0;
  color: #333;
}

.confirm-content {
  padding: 20px 0;
}

.action-info {
  margin: 20px 0;
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.action-info p {
  margin: 10px 0;
  color: #666;
}

.confirm-buttons {
  margin-top: 30px;
  text-align: right;
}

.confirm-buttons .el-button {
  margin-left: 10px;
}
</style>