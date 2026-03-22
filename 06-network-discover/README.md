# Network Discover

一款 macOS 原生桌面應用，用於掃描區域網路中的設備，支援 Port 掃描、HTTP Header 檢視與網路拓撲視覺化。

## 功能

- **設備掃描** — 掃描當前子網段，列出所有在線設備（IP、MAC、主機名稱）
- **Port 掃描** — 對指定設備進行 TCP Port 掃描，並顯示常見 Port 的用途說明
- **HTTP Header 檢視** — 對設備的 HTTP / HTTPS 端口發送請求，顯示回應標頭
- **網路拓撲** — 以節點圖方式呈現設備與閘道器之間的連接關係
- **掃描快取** — 使用 Hive 儲存掃描結果，重啟後仍可查看上次紀錄
- **多語言支援** — 支援繁體中文與英文介面（依系統語言自動切換）

## 技術架構

| 層級 | 技術 |
|------|------|
| 框架 | Flutter (macOS Desktop) |
| 狀態管理 | flutter_riverpod |
| 路由 | go_router |
| 本地儲存 | hive_flutter |
| 環境變數 | flutter_dotenv |
| 國際化 | flutter_localizations + intl |

### 專案結構

```
lib/
├── main.dart               # 應用進入點
├── router.dart             # go_router 路由設定
├── models/                 # 資料模型（NetworkDevice、PortInfo、AppSettings 等）
├── services/               # 業務邏輯（掃描、Ping、Port 掃描、HTTP Header、Hive）
├── providers/              # Riverpod Provider
├── screens/                # 三個主畫面（Scanner、Topology、Settings）
├── widgets/                # 可重用元件（DeviceCard、DeviceDetailSheet 等）
├── data/                   # 靜態資料（Port 名稱對照表）
├── theme/                  # 應用主題
└── l10n/                   # 本地化字串（en、zh）
```

## 開發環境需求

- Flutter SDK `^3.11.3`
- Dart SDK `^3.11.3`
- macOS（此應用僅支援 macOS 平台）
- 建議使用 [FVM](https://fvm.app/) 管理 Flutter 版本（專案已含 `.fvm/` 設定）

## 快速開始

```bash
# 安裝相依套件
flutter pub get

# 執行（macOS）
flutter run -d macos
```

### 環境變數

專案根目錄需有 `.env` 檔案，內容範例：

```env
APP_NAME=Network Discover
```

## 學習重點

此專案為 `2026-learning` 系列的第 6 個練習，涵蓋以下概念：

- Riverpod 狀態管理（AsyncNotifier、Provider 組合）
- go_router 多頁路由
- Hive 本地資料持久化
- Flutter macOS Desktop 原生整合
- flutter_localizations 多語言架構
- 使用 `dart:io` Socket 實作 TCP Port 掃描
