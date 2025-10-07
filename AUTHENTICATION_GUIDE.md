# ChefVentory Authentication System

## Overview

The ChefVentory app now features a comprehensive role-based authentication system with separate flows for Admin and Staff users. The system uses Firebase Authentication and Firestore for user management and data storage.

## Features

### 🔐 Role-Based Authentication
- **Admin Access**: Full restaurant management capabilities
- **Staff Access**: Limited access for inventory and order processing

### 🏢 Admin Features
- **Sign Up**: Create new restaurant with auto-generated Restaurant ID
- **Sign In**: Access admin dashboard with full privileges
- **Restaurant Management**: Manage staff and restaurant settings
- **Unique Email Validation**: One admin email per restaurant

### 👥 Staff Features
- **Sign Up**: Join restaurant with admin approval via OTP
- **Sign In**: Access staff dashboard with limited privileges
- **OTP Verification**: Admin receives OTP to verify new staff members
- **Email Validation**: Prevents duplicate staff accounts

## User Flow

### 1. Role Selection
Users first choose their role (Admin or Staff) on the main screen.

### 2. Admin Flow

#### Admin Sign Up:
1. Enter restaurant name
2. Enter email address
3. Create password
4. Confirm password
5. System generates unique Restaurant ID
6. Account created and redirected to admin dashboard

#### Admin Sign In:
1. Enter email address
2. Enter password
3. Sign in and access admin dashboard

### 3. Staff Flow

#### Staff Sign Up:
1. Enter admin's email address
2. Enter your email address
3. Create password
4. Confirm password
5. OTP sent to admin for verification
6. Enter OTP received from admin
7. Account verified and access granted

#### Staff Sign In:
1. Enter email address
2. Enter password
3. Sign in and access staff dashboard

## Technical Implementation

### File Structure
```
lib/
├── providers/
│   └── auth_provider.dart          # Authentication logic
├── screens/
│   ├── auth/
│   │   ├── role_selection_screen.dart     # Role selection
│   │   ├── admin_auth_screen.dart         # Admin login/signup
│   │   ├── staff_auth_screen.dart         # Staff login/signup
│   │   └── login_screen.dart              # Legacy login (demo)
│   ├── admin/
│   │   └── admin_dashboard.dart           # Admin dashboard
│   └── staff/
│       └── staff_dashboard.dart           # Staff dashboard
└── models/
    └── user.dart                          # User model
```

### Key Components

#### AuthProvider
- Manages Firebase Authentication state
- Handles user registration and login
- Manages OTP verification for staff
- Provides role-based access control

#### Role Selection Screen
- Modern UI for choosing user role
- Navigates to appropriate authentication flow

#### Admin Auth Screen
- Tabbed interface for Sign In/Sign Up
- Restaurant creation with auto-generated ID
- Form validation and error handling

#### Staff Auth Screen
- Tabbed interface for Sign In/Sign Up
- OTP verification system
- Admin email validation

## Database Schema

### Users Collection
```json
{
  "uid": "firebase_user_id",
  "username": "user_display_name",
  "email": "user@example.com",
  "role": "admin" | "staff",
  "restaurantId": "REST_XXXXXXXX",
  "isVerified": true,
  "createdAt": "timestamp"
}
```

### Restaurants Collection
```json
{
  "restaurantId": "REST_XXXXXXXX",
  "name": "Restaurant Name",
  "adminEmail": "admin@example.com",
  "createdAt": "timestamp",
  "isActive": true
}
```

### Pending Staff Verifications Collection
```json
{
  "staffUid": "firebase_user_id",
  "staffEmail": "staff@example.com",
  "adminEmail": "admin@example.com",
  "restaurantId": "REST_XXXXXXXX",
  "otp": "123456",
  "createdAt": "timestamp",
  "expiresAt": "timestamp"
}
```

## Security Features

### 🔒 Email Uniqueness
- Admin emails are unique across the system
- Staff emails are unique across the system
- Prevents duplicate accounts

### 🔐 OTP Verification
- 6-digit OTP for staff verification
- 10-minute expiration time
- Admin approval required for staff access

### 🛡️ Role-Based Access
- Admins have full restaurant access
- Staff have limited dashboard access
- Authentication state managed globally

### 🔍 Input Validation
- Email format validation
- Password strength requirements (min 6 characters)
- Form validation with error messages
- Real-time error feedback

## Usage Instructions

### For Developers

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Firebase Setup**:
   - Ensure Firebase is properly configured
   - Authentication and Firestore should be enabled
   - Update `firebase_options.dart` with your config

3. **Run the App**:
   ```bash
   flutter run
   ```

### For Users

1. **First Time Setup (Admin)**:
   - Choose "Restaurant Admin"
   - Click "Sign Up" tab
   - Fill in restaurant details
   - Your Restaurant ID will be generated automatically

2. **Adding Staff Members**:
   - Staff members choose "Staff Member"
   - They enter your admin email during signup
   - You'll receive an OTP to verify them
   - Share the OTP with your staff member

3. **Daily Usage**:
   - Use "Sign In" for regular access
   - Admins get full dashboard access
   - Staff get limited dashboard access

## Demo Credentials

For testing purposes, the system includes demo credentials:

**Admin Demo**:
- Username: `admin`
- Password: `admin123`

**Staff Demo**:
- Username: `staff`
- Password: `staff123`

## Color Scheme

The authentication system uses the ChefVentory color palette:
- **Primary Brown**: `#4c3025` - Admin theme color
- **Secondary Brown**: `#af8043` - Staff theme color
- **Cream Background**: `#FFF8F0` - Main background
- **Success Green**: `#4CAF50` - Success states
- **Error Red**: `#F44336` - Error states
- **Warning Yellow**: `#FFC107` - Warning states

## Future Enhancements

- [ ] Email notifications for OTP (currently demo mode)
- [ ] Password reset functionality
- [ ] Multi-factor authentication
- [ ] Advanced role permissions
- [ ] Restaurant invitation system
- [ ] Bulk staff management
- [ ] Activity logging and audit trails

## Troubleshooting

### Common Issues

1. **OTP Not Working**: 
   - Currently in demo mode, OTP is displayed on screen
   - In production, implement email service

2. **Firebase Connection**:
   - Verify `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Check Firebase project configuration

3. **Authentication State**:
   - Clear app data if authentication state is stuck
   - Check Firebase console for user status

### Error Messages

- "Admin email not found" - Admin must create account first
- "Account not verified by admin" - Staff needs OTP verification
- "Invalid credentials" - Check email/password combination
- "Email already exists" - User already registered

## Support

For technical support or questions about the authentication system, please refer to the Firebase documentation or contact the development team.