from app import create_app
import logging

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = create_app()

if __name__ == '__main__':
    try:
        logger.info("Starting Flask application...")
        # 关闭调试模式以确保服务稳定运行
        app.run(debug=False, host='0.0.0.0', port=5000)
    except Exception as e:
        logger.error(f"Error occurred: {str(e)}")
        import traceback
        logger.error(traceback.format_exc())
        # 保持程序运行
        input("Press Enter to exit...")