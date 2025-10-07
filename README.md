# Chefventory - Restaurant Inventory Management System

A comprehensive Flutter application for managing restaurant inventory with smart alerts, role-based access, and real-time tracking.

## 🍽️ Features

### Admin Dashboard
- **Alert Center**: Track low stock, expiring, and expired ingredients
- **System Statistics**: Overview of total ingredients, dishes, and orders
- **Analytics**: Performance metrics, waste tracking, and usage patterns
- **User Management**: Role-based access control
- **Quick Actions**: Fast access to common tasks

### Staff Dashboard
- **Today's Alerts**: Relevant notifications for daily operations
- **Order Processing**: Real-time order management with inventory checks
- **Inventory Overview**: Current stock levels and availability
- **Quick Actions**: Streamlined workflow for staff operations

### Core Functionality
- **Smart Alerts**: Automatic notifications for low stock and expiring items
- **Real-time Updates**: Live inventory tracking during order processing
- **Role-based Access**: Separate interfaces for Admin and Staff
- **Inventory Management**: Add, update, and track ingredients
- **Order Processing**: Process orders with automatic stock consumption
- **Analytics Dashboard**: Comprehensive reporting and insights

## 🎨 Design

The app features a modern food delivery-inspired design with:
- **Color Palette**: Vibrant orange (#FF6B35), rich brown (#8D4E2A), and clean whites
- **Material Design 3**: Modern UI components and animations
- **Responsive Layout**: Optimized for mobile and tablet devices
- **Intuitive Navigation**: Bottom navigation with clear visual hierarchy

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project (optional, for production)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd chefventory
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Demo Credentials

**Admin Access:**
- Username: `admin`
- Password: `admin123`

**Staff Access:**
- Username: `staff`
- Password: `staff123`

## 📱 Screenshots

### Login Screen
- Clean, modern authentication interface
- Demo credentials for easy testing
- Food delivery app-inspired design

### Admin Dashboard
- Comprehensive overview with alert center
- System statistics and analytics
- Quick action buttons for common tasks

### Staff Dashboard
- Operational interface for daily tasks
- Today's alerts and notifications
- Quick order processing capabilities

### Inventory Management
- Real-time stock tracking
- Add/edit ingredients with expiry dates
- Smart filtering and search functionality

### Order Processing
- Visual dish availability indicators
- Real-time inventory consumption
- Order summary and confirmation

## 🏗️ Architecture

### State Management
- **Provider Pattern**: Centralized state management
- **AuthProvider**: User authentication and role management
- **InventoryProvider**: Inventory data and operations

### Models
- **User**: Role-based user management
- **Ingredient**: Stock tracking with expiry dates
- **Dish**: Menu items with ingredient requirements
- **Inventory**: Centralized inventory management

### Key Features
- **Smart Alerts**: Automatic threshold-based notifications
- **Real-time Updates**: Live inventory tracking
- **Role-based UI**: Different interfaces for Admin/Staff
- **Data Persistence**: Firebase integration ready

## 🔧 Configuration

### Firebase Setup (Optional)
1. Create a Firebase project
2. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Update `firebase_options.dart` with your configuration

### Customization
- **Colors**: Modify `lib/theme/app_theme.dart`
- **Sample Data**: Update `lib/data/sample_data.dart`
- **Models**: Extend existing models in `lib/models/`

## 📊 Sample Data

The app includes comprehensive sample data:
- **10+ Ingredients**: Various food items with realistic stock levels
- **6+ Dishes**: Complete menu with ingredient requirements
- **Alert Scenarios**: Low stock, expiring, and expired items
- **User Accounts**: Admin and staff demo accounts

## 🚀 Future Enhancements

- **Firebase Integration**: Real-time cloud synchronization
- **Barcode Scanning**: Quick ingredient addition
- **Push Notifications**: Real-time alerts
- **Reporting**: Advanced analytics and reports
- **Multi-location**: Support for multiple restaurant locations
- **API Integration**: Connect with POS systems

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions, please open an issue in the repository.

---

**Chefventory** - Smart inventory management for modern restaurants 🍽️