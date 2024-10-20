import picker from '@ohos.file.picker';
import promptAction from '@ohos.promptAction';
import { DatabaseService } from '../services/DatabaseService';
import fs from '@ohos.file.fs';
import hilog from '@ohos.hilog';
import buffer from '@ohos.buffer';

@Entry
@Component
struct DataManagementPage {

  private dbService: DatabaseService;
  async  aboutToAppear() {
    this.dbService = await DatabaseService.getInstance()
  }

  build() {
    Column() {
      Text('数据管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      Button('导出备份数据库')
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .onClick(() => this.exportData())

      Button('导入备份数据库')
        .width('80%')
        .height(50)
        .onClick(() => this.importData())
        .margin({ bottom: 20 })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }


  async exportData() {
    try {
      // 备份数据库
      await this.dbService.backupDatabase();
      let DBDir = this.dbService.backupDBDir();

      // 设置文件选择器选项
      let options = new picker.DocumentSaveOptions();
      options.newFileNames = ['GTDdata.db'];
      let filePicker = new picker.DocumentViewPicker();

      try {
        // 使用文件选择器让用户选择保存位置
        let result = await filePicker.save(options);
        if (result && result.length > 0) {
          let targetURI = result[0];

          try {
            // 打开目标文件
            let targetFile = await fs.open(targetURI, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

            try {
              // 复制文件
              await fs.copyFile(DBDir, targetFile.fd);
              promptAction.showToast({ message: `数据已成功导出到: ${targetURI}` });
            } catch (copyError) {
              console.error('复制文件失败: ', copyError.message, copyError.code);
              promptAction.showToast({ message: '导出失败: 复制文件时出错' });
            } finally {
              // 无论是否成功，都要关闭文件
              await fs.close(targetFile.fd);
            }
          } catch (fileError) {
            console.error('打开目标文件失败: ', fileError.message, fileError.code);
            promptAction.showToast({ message: '导出失败: 无法打开目标文件' });
          }
        } else {
          promptAction.showToast({ message: '导出取消: 未选择保存位置' });
        }
      } catch (pickerError) {
        console.error('文件选择器错误: ', JSON.stringify(pickerError));
        promptAction.showToast({ message: '导出失败: 文件选择器错误' });
      }
    } catch (backupError) {
      console.error(`备份数据库失败: ${backupError.message}`);
      promptAction.showToast({ message: `导出失败: 备份数据库时出错` });
    }
  }




  async importData() {
    try {
      let DBDir = this.dbService.backupDBDir();
      let options = new picker.DocumentSelectOptions();
      let filePicker = new picker.DocumentViewPicker();

      try {
        let selectedFiles = await filePicker.select(options);
        if (selectedFiles && selectedFiles.length > 0) {
          let selectedURI = selectedFiles[0];

          try {
            let sourceFile = await fs.open(selectedURI, fs.OpenMode.READ_ONLY);

            try {
              await fs.copyFile(sourceFile.fd, DBDir);
              promptAction.showToast({ message: '文件导入成功' });

              // 从导入的文件恢复到数据库
              await this.dbService.restoreDatabase();
              promptAction.showToast({ message: '数据库恢复成功' });
            } catch (copyError) {
              console.error('导入文件失败:', copyError.message, copyError.code);
              promptAction.showToast({ message: '导入失败: 复制文件时出错' });
            } finally {
              // 确保文件被关闭
              await fs.close(sourceFile.fd);
            }
          } catch (fileError) {
            console.error('打开源文件失败:', fileError.message, fileError.code);
            promptAction.showToast({ message: '导入失败: 无法打开源文件' });
          }
        } else {
          promptAction.showToast({ message: '导入取消: 未选择文件' });
        }
      } catch (pickerError) {
        console.error('文件选择器错误:', JSON.stringify(pickerError));
        promptAction.showToast({ message: '导入失败: 文件选择器错误' });
      }
    } catch (error) {
      console.error('导入过程中发生错误:', JSON.stringify(error));
      promptAction.showToast({ message: '导入失败: 未知错误' });
    }
  }





  pageTransition() {
    PageTransitionEnter({ duration: 200, curve: Curve.EaseOut })
      .slide(SlideEffect.Right)
    PageTransitionExit({ duration: 200, curve: Curve.EaseIn })
      .opacity(0)
  }
}