# Deployment Architecture - SmartSpender

Kiến trúc triển khai hệ thống SmartSpender - phiên bản cho slide thuyết trình.

## Biểu đồ Deployment

```mermaid
graph TB
    subgraph SCM["📚 Source Control"]
        GH["GitHub Repository<br/>(main branch)"]
    end

    subgraph CI["🔄 CI/CD Pipeline"]
        GA["GitHub Actions<br/>Automated Deploy"]
    end

    subgraph BACKEND["🖥️ Backend Deployment"]
        RENDER["Render Platform<br/>Node.js + Express<br/>https://smartspender-x1fl.onrender.com"]
    end

    subgraph DATABASE["💾 Database"]
        MONGO["MongoDB Atlas<br/>(Cloud Cluster)"]
    end

    subgraph WEB["🌐 Web Deployment"]
        GHPAGES["GitHub Pages<br/>Flutter Web<br/>(flutter build web)"]
    end

    subgraph MOBILE["📱 Mobile Deployment"]
        PLAYSTORE["Google Play Store<br/>(Android APK)"]
        APPSTORE["Apple App Store<br/>(iOS IPA)"]
    end

    subgraph USERS["👥 End Users"]
        BROWSER["Web Browser"]
        ANDROID["Android Device"]
        IOS["iOS Device"]
    end

    subgraph HEALTH["🏥 Health Check"]
        MONITOR["Health Monitor<br/>(every 15 min)"]
    end

    %% Connections
    GH -->|Push main| GA
    GA -->|Deploy Backend| RENDER
    GA -->|Deploy Web| GHPAGES
    GA -->|Build Mobile| PLAYSTORE
    GA -->|Build Mobile| APPSTORE

    RENDER --> MONGO
    GHPAGES --> BROWSER
    PLAYSTORE --> ANDROID
    APPSTORE --> IOS

    RENDER -.->|Check Status| MONITOR
    MONITOR -.->|Alert on Error| GH

    BROWSER -->|Access| GHPAGES
    ANDROID -->|Download| PLAYSTORE
    IOS -->|Download| APPSTORE

    style SCM fill:#e1f5ff
    style CI fill:#fff3e0
    style BACKEND fill:#f3e5f5
    style DATABASE fill:#e8f5e9
    style WEB fill:#fce4ec
    style MOBILE fill:#f1f8e9
    style USERS fill:#ede7f6
    style HEALTH fill:#ffe0b2
```

## Chi tiết triển khai

| Component        | Công nghệ        | Mô tả                                                     |
| ---------------- | ---------------- | --------------------------------------------------------- |
| **Source Code**  | GitHub           | Repository chính trên GitHub, nhánh `main` là production  |
| **CI/CD**        | GitHub Actions   | Tự động trigger khi push lên `main`                       |
| **Backend**      | Render + Node.js | REST API server triển khai trên Render platform           |
| **Database**     | MongoDB Atlas    | Cloud database, kết nối qua connection string             |
| **Web**          | GitHub Pages     | Flutter Web build, tự động deploy qua API                 |
| **Android**      | Play Store       | APK build qua GitHub Actions, đẩy thủ công lên Play Store |
| **iOS**          | App Store        | IPA build qua GitHub Actions, đẩy thủ công lên App Store  |
| **Health Check** | Monitor Script   | Kiểm tra backend mỗi 15 phút, alert nếu down              |

## Quy trình triển khai từng phần

### 1️⃣ Backend (Automatic)

```
Git Push (main)
    ↓
GitHub Actions trigger
    ↓
Build Node.js app
    ↓
Deploy to Render
    ↓
Health check: OK
```

### 2️⃣ Web (Automatic)

```
Git Push (main)
    ↓
GitHub Actions trigger
    ↓
flutter build web --release
    ↓
Push to GitHub Pages
    ↓
Live at: https://<username>.github.io/SmartSpender/
```

### 3️⃣ Mobile (Semi-automatic)

```
Git Push (main)
    ↓
GitHub Actions trigger
    ↓
flutter build apk/ipa
    ↓
Manual upload to Play Store / App Store
    ↓
Review & publish
```

## Biến môi trường triển khai

### Backend (Render)

```
PORT=3000
MONGODB_URI=mongodb+srv://<user>:<pass>@cluster.mongodb.net/smartspender
JWT_SECRET=<secure-key>
NODE_ENV=production
```

### Web (GitHub Pages)

```
API_BASE_URL=https://smartspender-x1fl.onrender.com/api/v1
APP_ENV=production
```

### Mobile (Build config)

```
API_BASE_URL=https://smartspender-x1fl.onrender.com/api/v1
APP_ENV=production
```

## Monitoring & Alerts

- **Health Check**: Mỗi 15 phút gọi `GET /api/health` trên Backend
- **Response Time**: Monitor performance metrics
- **Error Logs**: Ghi nhận lỗi 5xx từ API
- **Alert Channel**: Email/Slack khi backend down > 5 phút

## Scaling & Performance

- **Backend**: Render auto-scaling (based on traffic)
- **Database**: MongoDB Atlas multi-region replication
- **Web**: GitHub Pages CDN global
- **Mobile**: Direct download từ app stores

---

**Cập nhật:** 01/04/2026 | **Status:** Production Ready
