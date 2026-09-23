// tarBar/Dev.ets
import { http } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';

interface Greenhouse {
  id: string;
  name: string;
}

// 设备数据接口
interface DeviceItem {
  id: string;
  name: string;
  icon: string;
  status: boolean;
  type: 'pump' | 'light' | 'buzzer';
}

// 控制指令响应接口
interface ControlResponse {
  code: number;
  message: string;
}

// 命令数据接口
interface CommandData {
  device: string;
  action: string;
  greenhouse: string;
}

// 模式切换数据接口
interface ModeData {
  mode: string;
  greenhouse: string;
}
@Entry
@Component
export struct Dev {
  @State greenhouses: Greenhouse[] = [
    { id: '1', name: '1号大棚' },
    { id: '2', name: '2号大棚' },
    { id: '3', name: '3号大棚' }
  ];

  @State currentGreenhouse: string = '1号大棚';
  @State controlMode: string = 'manual';

  @State devices: DeviceItem[] = [
    { id: '1', name: '水泵', icon: '💧', status: false, type: 'pump' },
    { id: '2', name: '补光灯', icon: '💡', status: false, type: 'light' },
    { id: '3', name: '蜂鸣器', icon: '🔔', status: false, type: 'buzzer' }
  ];

  @State showDropdown: boolean = false;
  @State isLoading: boolean = false;

  private httpRequest: http.HttpRequest | null = null;

  aboutToAppear() {
    this.httpRequest = http.createHttp();
  }

  aboutToDisappear() {
    if (this.httpRequest) {
      this.httpRequest.destroy();
      this.httpRequest = null;
    }
  }

  build() {
    Stack() {
      Image($r('app.media.bg_dev'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.1)')

      Column() {
        Row() {
          Text('📱 设备控制')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .shadow({ radius: 4, color: '#00000020', offsetX: 0, offsetY: 2 })

          Blank()

          Text(this.currentGreenhouse)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('rgba(255, 255, 255, 0.25)')
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .borderRadius(12)
            .backdropBlur(10)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16 })

        Scroll() {
          Column() {
            // ==================== 大棚选择区域 ====================
            Column() {
              Row() {
                Text('🏠 当前大棚')
                  .fontSize(14)
                  .fontColor('#666666')

                Blank()

                Row() {
                  Text(this.currentGreenhouse)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')

                  Text(this.showDropdown ? '▲' : '▼')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ left: 8 })
                }
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .backgroundColor('#FFFFFF')
                .borderRadius(10)
                .border({ width: 1, color: '#E0E0E0' })
                .onClick(() => {
                  this.showDropdown = !this.showDropdown;
                })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 14, bottom: 12 })

              if (this.showDropdown) {
                Column() {
                  ForEach(this.greenhouses, (item: Greenhouse) => {
                    Row() {
                      Text(item.name)
                        .fontSize(15)
                        .fontColor(this.currentGreenhouse === item.name ? '#4CAF50' : '#333333')
                        .fontWeight(this.currentGreenhouse === item.name ? FontWeight.Bold : FontWeight.Normal)

                      if (this.currentGreenhouse === item.name) {
                        Text('✓')
                          .fontSize(16)
                          .fontColor('#4CAF50')
                          .margin({ left: 8 })
                      }
                    }
                    .width('100%')
                    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                    .onClick(() => {
                      this.currentGreenhouse = item.name;
                      this.showDropdown = false;
                    })
                    .backgroundColor(this.currentGreenhouse === item.name ? '#4CAF5010' : '#FFFFFF')
                  })
                }
                .width('100%')
                .backgroundColor('#FFFFFF')
                .borderRadius(10)
                .border({ width: 1, color: '#E0E0E0' })
                .margin({ left: 16, right: 16, bottom: 14 })
                .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 4 })
              }
            }
            .width('100%')
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .borderRadius(16)
            .margin({ top: 16, left: 16, right: 16 })
            .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 4 })

            // ==================== 控制模式切换 ====================
            Column() {
              Row() {
                Text('🎮 控制模式')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Blank()

                Row() {
                  Text('自动')
                    .fontSize(14)
                    .fontWeight(this.controlMode === 'auto' ? FontWeight.Bold : FontWeight.Normal)
                    .fontColor(this.controlMode === 'auto' ? '#FFFFFF' : '#666666')
                    .width(70)
                    .height(36)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(this.controlMode === 'auto' ? '#4CAF50' : '#F5F5F5')
                    .borderRadius({ topLeft: 18, bottomLeft: 18 })
                    .onClick(() => {
                      this.controlMode = 'auto';
                      this.sendModeChange('auto');
                    })

                  Text('手动')
                    .fontSize(14)
                    .fontWeight(this.controlMode === 'manual' ? FontWeight.Bold : FontWeight.Normal)
                    .fontColor(this.controlMode === 'manual' ? '#FFFFFF' : '#666666')
                    .width(70)
                    .height(36)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(this.controlMode === 'manual' ? '#2196F3' : '#F5F5F5')
                    .borderRadius({ topRight: 18, bottomRight: 18 })
                    .onClick(() => {
                      this.controlMode = 'manual';
                      this.sendModeChange('manual');
                    })
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 16, bottom: 16 })

              Row() {
                Text(this.controlMode === 'auto' ? '🤖 自动控制模式 - 设备将根据预设条件自动运行' : '✋ 手动控制模式 - 可自由控制设备开关')
                  .fontSize(12)
                  .fontColor(this.controlMode === 'auto' ? '#4CAF50' : '#2196F3')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 12 })
              .backgroundColor(this.controlMode === 'auto' ? '#4CAF5010' : '#2196F310')
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })
            }
            .width('100%')
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .borderRadius(16)
            .margin({ top: 12, left: 16, right: 16 })
            .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 4 })

            // ==================== 设备列表标题 ====================
            Row() {
              Text('📋 设备列表')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2E7D32')

              Blank()

              Text(`${this.devices.length} 个设备`)
                .fontSize(12)
                .fontColor('#999999')
                .backgroundColor('#F5F5F5')
                .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                .borderRadius(10)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            .margin({ top: 20, bottom: 12 })

            // ==================== 设备卡片列表 ====================
            Column() {
              ForEach(this.devices, (device: DeviceItem, index: number) => {
                Column() {
                  Row() {
                    Column() {
                      Text(device.icon)
                        .fontSize(32)
                    }
                    .width(56)
                    .height(56)
                    .backgroundColor(this.getDeviceColor(device.type) + '20')
                    .borderRadius(14)
                    .justifyContent(FlexAlign.Center)
                    .margin({ right: 14 })

                    Column() {
                      Text(device.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')

                      Row() {
                        Circle({ width: 6, height: 6 })
                          .fill(device.status ? '#4CAF50' : '#CCCCCC')

                        Text(device.status ? '运行中' : '已关闭')
                          .fontSize(11)
                          .fontColor(device.status ? '#4CAF50' : '#999999')
                          .margin({ left: 6 })
                      }
                      .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)

                    Blank()

                    if (this.isLoading) {
                      LoadingProgress()
                        .width(24)
                        .height(24)
                        .color('#4CAF50')
                    } else {
                      Toggle({ type: ToggleType.Switch, isOn: device.status })
                        .selectedColor('#4CAF50')
                        .width(50)
                        .enabled(this.controlMode !== 'auto')
                        .onChange((isOn: boolean) => {
                          device.status = isOn;
                          this.onDeviceToggle(device, isOn);
                        })
                    }
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })

                  if (index < this.devices.length - 1) {
                    Divider()
                      .strokeWidth(0.5)
                      .color('#F0F0F0')
                      .margin({ left: 86, right: 16 })
                  }
                }
              }, (device: DeviceItem) => device.id + '_' + device.status)
            }
            .width('100%')
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .borderRadius(16)
            .margin({ left: 16, right: 16 })
            .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 4 })

            Column()
              .width('100%')
              .height(100)
          }
          .padding({ bottom: 20 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  getDeviceColor(type: string): string {
    switch (type) {
      case 'pump':
        return '#2196F3';
      case 'light':
        return '#FF9800';
      case 'buzzer':
        return '#F44336';
      default:
        return '#4CAF50';
    }
  }

  // 安全获取响应字符串
  private getResponseString(result: string | Object | ArrayBuffer): string {
    console.log('🔍 getResponseString 输入类型:', typeof result);

    if (typeof result === 'string') {
      return result;
    } else if (result instanceof ArrayBuffer) {
      const textDecoder = util.TextDecoder.create('utf-8');
      const uint8Array = new Uint8Array(result);
      const decodedStr = textDecoder.decodeToString(uint8Array);
      console.log('🔍 ArrayBuffer 解码结果:', decodedStr);
      return decodedStr;
    } else {
      const jsonStr = JSON.stringify(result);
      console.log('🔍 Object 转 JSON:', jsonStr);
      return jsonStr;
    }
  }

  // 发送设备开关指令
  async onDeviceToggle(device: DeviceItem, isOn: boolean) {
    if (!this.httpRequest) {
      console.error('❌ HTTP请求对象未初始化');
      device.status = !isOn;
      return;
    }

    this.isLoading = true;
    console.log(`📤 发送控制指令: ${device.name} -> ${isOn ? '开' : '关'}`);

    try {
      const commandData: CommandData = {
        device: device.type,
        action: isOn ? 'on' : 'off',
        greenhouse: this.currentGreenhouse
      };

      console.log('📤 请求数据:', JSON.stringify(commandData));

      const responseData = await this.httpRequest.request(
        "http://192.168.99.46:8080/api/device/control",
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(commandData),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      const responseStr = this.getResponseString(responseData.result);
      console.log('📥 服务器响应:', responseStr);
      console.log('📥 响应类型:', typeof responseStr);

      // 安全解析 JSON
      let response: ControlResponse;
      try {
        response = JSON.parse(responseStr) as ControlResponse;
      } catch (parseError) {
        console.error('❌ JSON解析失败, 原始响应:', responseStr);
        device.status = !isOn;
        promptAction.showToast({
          message: '服务器响应异常',
          duration: 2000
        });
        return;
      }

      if (response.code === 200) {
        promptAction.showToast({
          message: `${device.name} ${isOn ? '已开启' : '已关闭'}`,
          duration: 1500
        });
        console.log(`✅ ${device.name} 控制成功`);
      } else {
        device.status = !isOn;
        promptAction.showToast({
          message: `控制失败: ${response.message}`,
          duration: 2000
        });
        console.error(`❌ 控制失败: ${response.message}`);
      }
    } catch (error) {
      device.status = !isOn;
      console.error('❌ 发送控制指令失败:', JSON.stringify(error));
      promptAction.showToast({
        message: '网络错误，请检查连接',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 发送模式切换指令
  async sendModeChange(mode: string) {
    if (!this.httpRequest) {
      return;
    }

    console.log(`📤 切换控制模式: ${mode}`);

    try {
      const modeData: ModeData = {
        mode: mode,
        greenhouse: this.currentGreenhouse
      };

      const responseData = await this.httpRequest.request(
        "http://192.168.99.46:8080/api/mode/change",
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(modeData),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      const responseStr = this.getResponseString(responseData.result);
      console.log('📥 模式切换响应:', responseStr);

      // 安全解析 JSON
      let response: ControlResponse;
      try {
        response = JSON.parse(responseStr) as ControlResponse;
      } catch (parseError) {
        console.error('❌ 模式切换JSON解析失败, 原始响应:', responseStr);
        return;
      }

      if (response.code === 200) {
        promptAction.showToast({
          message: `已切换至${mode === 'auto' ? '自动' : '手动'}模式`,
          duration: 1500
        });
      }
    } catch (error) {
      console.error('❌ 模式切换失败:', JSON.stringify(error));
    }
  }
}