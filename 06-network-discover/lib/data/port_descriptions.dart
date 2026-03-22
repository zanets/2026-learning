enum PortRisk { safe, info, warn, danger }

class PortDescription {
  final String name;
  final String description;
  final PortRisk risk;
  final String? tips;

  const PortDescription({
    required this.name,
    required this.description,
    required this.risk,
    this.tips,
  });
}

const Map<int, PortDescription> kPortDescriptions = {
  // Web
  80: PortDescription(
    name: 'HTTP',
    description: '未加密的網頁服務',
    risk: PortRisk.warn,
    tips: '建議升級至 HTTPS (443)，避免明文傳輸',
  ),
  443: PortDescription(
    name: 'HTTPS',
    description: '加密的網頁服務',
    risk: PortRisk.safe,
  ),
  8080: PortDescription(
    name: 'HTTP Alternate',
    description: '替代 HTTP 連接埠，常用於開發或代理',
    risk: PortRisk.warn,
    tips: '確認是否為預期的服務，避免暴露開發環境',
  ),
  8443: PortDescription(
    name: 'HTTPS Alternate',
    description: '替代 HTTPS 連接埠',
    risk: PortRisk.info,
  ),
  3000: PortDescription(
    name: 'Dev Server',
    description: '常見開發伺服器連接埠 (Node.js/React 等)',
    risk: PortRisk.warn,
    tips: '不應暴露於生產環境',
  ),
  4200: PortDescription(
    name: 'Angular Dev',
    description: 'Angular 開發伺服器',
    risk: PortRisk.warn,
    tips: '不應暴露於生產環境',
  ),
  5000: PortDescription(
    name: 'Dev Server',
    description: '常見開發伺服器 (Flask/Python 等)',
    risk: PortRisk.warn,
    tips: '不應暴露於生產環境',
  ),
  8888: PortDescription(
    name: 'Jupyter Notebook',
    description: 'Jupyter Notebook 伺服器',
    risk: PortRisk.danger,
    tips: '確保已啟用身份驗證，避免遠端程式碼執行風險',
  ),
  9000: PortDescription(
    name: 'PHP-FPM / SonarQube',
    description: 'PHP FastCGI 或 SonarQube',
    risk: PortRisk.warn,
    tips: 'PHP-FPM 不應直接對外暴露',
  ),

  // Remote Access
  22: PortDescription(
    name: 'SSH',
    description: '安全 Shell 遠端存取',
    risk: PortRisk.info,
    tips: '使用金鑰認證取代密碼，並考慮更改預設連接埠',
  ),
  23: PortDescription(
    name: 'Telnet',
    description: '不安全的遠端登入協定',
    risk: PortRisk.danger,
    tips: '立即停用！所有資料均為明文傳輸，改用 SSH',
  ),
  3389: PortDescription(
    name: 'RDP',
    description: 'Windows 遠端桌面協定',
    risk: PortRisk.danger,
    tips: '限制存取 IP，啟用 NLA，並定期更新系統',
  ),
  5900: PortDescription(
    name: 'VNC',
    description: '虛擬網路運算（遠端桌面）',
    risk: PortRisk.danger,
    tips: '使用強密碼並透過 SSH 隧道存取',
  ),

  // File Transfer
  21: PortDescription(
    name: 'FTP',
    description: '檔案傳輸協定（明文）',
    risk: PortRisk.danger,
    tips: '使用 SFTP (22) 或 FTPS 取代',
  ),
  445: PortDescription(
    name: 'SMB',
    description: 'Windows 檔案共享',
    risk: PortRisk.danger,
    tips: '限制存取範圍，保持系統更新，防範勒索軟體',
  ),
  139: PortDescription(
    name: 'NetBIOS',
    description: 'Windows 網路芳鄰',
    risk: PortRisk.warn,
    tips: '若不需要應停用',
  ),
  2049: PortDescription(
    name: 'NFS',
    description: 'Network File System',
    risk: PortRisk.warn,
    tips: '嚴格控制存取清單，避免全域掛載',
  ),

  // Database
  3306: PortDescription(
    name: 'MySQL',
    description: 'MySQL 資料庫',
    risk: PortRisk.danger,
    tips: '不應暴露於公網，使用防火牆限制存取',
  ),
  5432: PortDescription(
    name: 'PostgreSQL',
    description: 'PostgreSQL 資料庫',
    risk: PortRisk.danger,
    tips: '不應暴露於公網，配置 pg_hba.conf 限制存取',
  ),
  1433: PortDescription(
    name: 'MSSQL',
    description: 'Microsoft SQL Server',
    risk: PortRisk.danger,
    tips: '不應暴露於公網，使用 Windows 驗證',
  ),
  27017: PortDescription(
    name: 'MongoDB',
    description: 'MongoDB 資料庫',
    risk: PortRisk.danger,
    tips: '預設無驗證！立即啟用身份驗證並限制 bindIP',
  ),
  6379: PortDescription(
    name: 'Redis',
    description: 'Redis 快取資料庫',
    risk: PortRisk.danger,
    tips: '預設無密碼！設定 requirepass 並限制 bind',
  ),
  9200: PortDescription(
    name: 'Elasticsearch',
    description: 'Elasticsearch 搜尋引擎',
    risk: PortRisk.danger,
    tips: '啟用安全功能，舊版本預設無驗證',
  ),
  11211: PortDescription(
    name: 'Memcached',
    description: 'Memcached 記憶體快取',
    risk: PortRisk.danger,
    tips: '不應暴露於公網，可被用於 DDoS 放大攻擊',
  ),

  // Email
  25: PortDescription(
    name: 'SMTP',
    description: '郵件傳送協定',
    risk: PortRisk.warn,
    tips: '防止開放轉發（open relay）',
  ),
  587: PortDescription(
    name: 'SMTP Submission',
    description: '郵件提交連接埠（需驗證）',
    risk: PortRisk.info,
  ),
  993: PortDescription(
    name: 'IMAPS',
    description: '加密 IMAP 郵件接收',
    risk: PortRisk.safe,
  ),
  995: PortDescription(
    name: 'POP3S',
    description: '加密 POP3 郵件接收',
    risk: PortRisk.safe,
  ),

  // DNS / Network
  53: PortDescription(
    name: 'DNS',
    description: '網域名稱系統',
    risk: PortRisk.info,
    tips: '確認是否允許遞迴查詢，防止 DNS 放大攻擊',
  ),
  67: PortDescription(
    name: 'DHCP Server',
    description: '動態主機設定協定（伺服器）',
    risk: PortRisk.info,
  ),
  123: PortDescription(
    name: 'NTP',
    description: '網路時間協定',
    risk: PortRisk.info,
    tips: '限制 monlist 查詢，防止 NTP 放大攻擊',
  ),
  161: PortDescription(
    name: 'SNMP',
    description: '簡單網路管理協定',
    risk: PortRisk.warn,
    tips: '使用 SNMPv3，更改預設 community string',
  ),

  // VPN
  1194: PortDescription(
    name: 'OpenVPN',
    description: 'OpenVPN 服務',
    risk: PortRisk.safe,
  ),
  51820: PortDescription(
    name: 'WireGuard',
    description: 'WireGuard VPN',
    risk: PortRisk.safe,
  ),
  1723: PortDescription(
    name: 'PPTP',
    description: '點對點隧道協定 VPN',
    risk: PortRisk.danger,
    tips: 'PPTP 已知有安全漏洞，改用 WireGuard 或 OpenVPN',
  ),

  // Container / DevOps
  2375: PortDescription(
    name: 'Docker (unencrypted)',
    description: 'Docker 守護程序（無加密）',
    risk: PortRisk.danger,
    tips: '嚴禁暴露！可被用來取得主機 root 權限',
  ),
  2376: PortDescription(
    name: 'Docker (TLS)',
    description: 'Docker 守護程序（TLS 加密）',
    risk: PortRisk.warn,
    tips: '確保 TLS 憑證設定正確',
  ),
  6443: PortDescription(
    name: 'Kubernetes API',
    description: 'Kubernetes API Server',
    risk: PortRisk.warn,
    tips: '使用 RBAC 嚴格控制存取',
  ),
  9090: PortDescription(
    name: 'Prometheus',
    description: 'Prometheus 監控系統',
    risk: PortRisk.warn,
    tips: '加入身份驗證，避免洩漏系統指標',
  ),

  // Message Queue
  5672: PortDescription(
    name: 'RabbitMQ',
    description: 'RabbitMQ AMQP',
    risk: PortRisk.warn,
    tips: '更改預設帳號密碼 guest/guest',
  ),
  15672: PortDescription(
    name: 'RabbitMQ Management',
    description: 'RabbitMQ 管理介面',
    risk: PortRisk.danger,
    tips: '更改預設帳號密碼，不應暴露於公網',
  ),
  9092: PortDescription(
    name: 'Kafka',
    description: 'Apache Kafka',
    risk: PortRisk.warn,
    tips: '啟用 TLS 和 SASL 驗證',
  ),

  // IoT / Printer
  9100: PortDescription(
    name: 'JetDirect (Printer)',
    description: '印表機 RAW 列印',
    risk: PortRisk.warn,
    tips: '限制存取，防止未授權列印',
  ),
  1883: PortDescription(
    name: 'MQTT',
    description: 'IoT 訊息協定',
    risk: PortRisk.warn,
    tips: '啟用 TLS 和驗證，預設無加密',
  ),

  // Home Automation
  8123: PortDescription(
    name: 'Home Assistant',
    description: 'Home Assistant 智慧家居',
    risk: PortRisk.info,
    tips: '啟用 MFA，使用反向代理加 HTTPS',
  ),

  // Proxy
  1080: PortDescription(
    name: 'SOCKS Proxy',
    description: 'SOCKS 代理伺服器',
    risk: PortRisk.warn,
    tips: '若非刻意設定，可能為惡意軟體',
  ),
  3128: PortDescription(
    name: 'Squid Proxy',
    description: 'Squid HTTP 代理',
    risk: PortRisk.warn,
    tips: '確認存取控制清單設定正確',
  ),

  // Windows
  135: PortDescription(
    name: 'RPC',
    description: 'Windows RPC Endpoint Mapper',
    risk: PortRisk.warn,
    tips: '限制外部存取',
  ),
  389: PortDescription(
    name: 'LDAP',
    description: '輕量目錄存取協定',
    risk: PortRisk.warn,
    tips: '使用 LDAPS (636) 加密',
  ),
  636: PortDescription(
    name: 'LDAPS',
    description: '加密 LDAP',
    risk: PortRisk.info,
  ),
  88: PortDescription(
    name: 'Kerberos',
    description: 'Kerberos 驗證',
    risk: PortRisk.info,
  ),
};
