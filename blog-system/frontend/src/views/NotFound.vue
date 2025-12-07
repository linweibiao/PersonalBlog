<template>
  <div class="not-found-container">
    <div class="not-found-content">
      <h1 class="error-code">404</h1>
      <h2 class="error-message">页面不存在</h2>
      <p class="error-description">抱歉，您访问的页面不存在或已被删除。</p>
      <el-button type="primary" @click="goHome" class="home-button">返回首页</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';

const router = useRouter();

const goHome = () => {
  router.push('/');
};
</script>

<style scoped>
.not-found-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 80vh;
  background-color: #f5f7fa;
}

.not-found-content {
  text-align: center;
  padding: 40px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  width: 90%;
}

.error-code {
  font-size: 80px;
  font-weight: bold;
  color: #409eff;
  margin: 0 0 20px 0;
}

.error-message {
  font-size: 24px;
  color: #303133;
  margin: 0 0 16px 0;
}

.error-description {
  color: #606266;
  margin-bottom: 32px;
  font-size: 16px;
}

.home-button {
  padding: 12px 36px;
  font-size: 16px;
}
</style>