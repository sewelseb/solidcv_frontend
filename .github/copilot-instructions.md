# GitHub Copilot Instructions for SolidCV

## Project Overview

SolidCV is a **Flutter-based CV/Resume management platform** that integrates blockchain technology for credential verification and AI-powered career guidance. The application combines traditional CV management with NFT-based certificates, work experience tokens, and smart career advice features.

### Core Technologies
- **Flutter/Dart**: Cross-platform mobile and web application
- **Blockchain**: Ethereum integration with Web3dart for NFT minting and wallet management
- **IPFS**: Distributed storage for certificates and work experience data
- **AI Integration**: Career advice, skill assessment, and profile feedback
- **Secure Storage**: JWT tokens and encrypted wallet management

## Architecture Patterns

### 1. Layered Architecture (Business Logic Layer Pattern)
```
Views/ (UI Layer)
├── business_layer/ (BLL - Business Logic)
├── data_access_layer/ (DAL - Data Access)
├── models/ (Data Models)
└── config/ (Configuration)
```

**Key Pattern**: All business logic is centralized in BLL classes that implement interfaces:
- `IUserBLL` → `UserBll`
- `ICompanyBll` → `CompanyBll` 
- `IBlockchainWalletBll` → `BlockchainWalletBll`
- `IEducationInstitutionBll` → `EducationInstitutionBll`

### 2. Service Layer Pattern
Data access is abstracted through service interfaces:
- `IUserService` → `UserService`
- `ICompanyService` → `CompanyService`
- `IWalletService` → `EtheriumWalletService`
- `IIPFSService` → `IPFSService`

### 3. Repository Pattern for Configuration
Centralized configuration classes:
- `BackenConnection`: API endpoints and base URLs
- `EtheriumConnection`: Blockchain network configuration
- `IPFSConnection`: IPFS gateway and API credentials

## File Naming Conventions

### Views (UI Components)
- **Route files**: `HomeRoute.dart`, `RegisterRoute.dart`, `MyCvRoute.dart`
- **Page files**: `AdminDashboardPage.dart`, `CreateJobOffer.dart`
- **Widget files**: `MainBottomNavigationBar.dart`, `MyEducation.dart`
- **Sub-components**: `UserVerifyCvEducationMobile.dart`, `AIFeaturesSection.dart`

### Business Layer
- **Interface naming**: `I{EntityName}BLL.dart` (e.g., `IUserBLL.dart`)
- **Implementation naming**: `{EntityName}Bll.dart` (e.g., `UserBLL.dart`)

### Data Access Layer
- **Service interfaces**: `I{EntityName}Service.dart`
- **Service implementations**: `{EntityName}Service.dart`
- **Blockchain services**: Located in `BlockChain/` subdirectory

### Models
- **Entity models**: `User.dart`, `Company.dart`, `Certificate.dart`
- **Request/Response models**: `CareerAdvice.dart`, `SearchTherms.dart`
- **IPFS models**: Located in `BlockChain/IPFSModels/`

## Code Style Guidelines

### 1. Class Structure
```dart
class UserBll extends IUserBLL {
  final IUserService _userService = UserService();
  
  @override
  Future<User> getCurrentUser() {
    return _userService.getCurrentUser();
  }
}
```

### 2. Dependency Injection Pattern
Services are injected through interfaces:
```dart
final IUserBLL _userBll = UserBll();
final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
```

### 3. State Management
Uses StatefulWidget with Future-based data loading:
```dart
late Future<User> _currentUserFuture;

@override
void initState() {
  super.initState();
  _currentUserFuture = _userBll.getCurrentUser();
}
```

### 4. API Integration Pattern
All HTTP calls use standardized headers with JWT authentication:
```dart
headers: <String, String>{
  'Content-Type': 'application/json; charset=UTF-8',
  'X-Auth-Token': await APIConnectionHelper.getJwtToken(),
}
```

## Model Serialization Patterns

### JSON Serialization
All models implement `fromJson` and `toJson` methods:
```dart
class User {
  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    // ... other fields
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    return data;
  }
}
```

### Nullable Safety
Uses Dart null safety throughout:
- Nullable fields: `String?`, `int?`
- Non-nullable with defaults: Required parameters in constructors
- Safe navigation: `user.ethereumAddress?.isNotEmpty ?? false`

## Routing and Navigation

### Named Routes
All navigation uses named routes defined in `main.dart`:
```dart
routes: {
  '/': (context) => const HomeRoute(),
  '/loggedin/home': (context) => const AuthGuard(child: LoggedInHome()),
  '/career-advice': (context) => const AuthGuard(child: CareerAdviceMain()),
}
```

### AuthGuard Pattern
Protected routes are wrapped with `AuthGuard`:
```dart
'/admin/dashboard': (context) => const AuthGuard(child: AdminDashboardPage()),
```

### Dynamic Route Handling
Parameterized routes use `onGenerateRoute`:
```dart
if (settings.name!.startsWith('/user/')) {
  final id = settings.name!.substring('/user/'.length);
  return MaterialPageRoute(
    builder: (context) => AuthGuard(child: UserPage(userId: id)),
  );
}
```

## Responsive Design Patterns

### Breakpoint-Based Layout
Uses consistent breakpoints:
```dart
final bool isMobile = screenWidth < 768;
final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
```

### Adaptive Widgets
Components adapt to screen size:
```dart
Widget build(BuildContext context) {
  return isMobile 
    ? _buildMobileLayout() 
    : _buildDesktopLayout();
}
```

## Blockchain Integration Patterns

### Wallet Management
- Private keys stored encrypted in `FlutterSecureStorage`
- Wallet addresses linked to user profiles
- Support for both Ethereum and NEAR protocols

### NFT Minting Pattern
```dart
final tokenAddress = await _walletService.mintWorkExperienceToken(
  privateKey,
  company.ethereumAddress!,
  receiver.ethereumAddress!,
  ipfsUrl,
);
```

### IPFS Storage
Documents and metadata stored on IPFS with Pinata integration:
```dart
final cid = await _ipfsService.saveWorkEvent(event);
final url = IPFSConnection().gatewayUrl + cid;
```

## Error Handling Conventions

### Exception Handling
```dart
try {
  final result = await _service.performOperation();
  return result;
} catch (e) {
  throw Exception('Operation failed: $e');
}
```

### UI Error Display
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: $errorMessage')),
);
```

## Testing Patterns

### Future Builder Testing
UI components use `FutureBuilder` for async data:
```dart
FutureBuilder<User>(
  future: _currentUserFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text("Error: ${snapshot.error}");
    }
    return _buildUserContent(snapshot.data!);
  },
)
```

## Security Best Practices

### JWT Token Management
```dart
const storage = FlutterSecureStorage();
final token = await storage.read(key: 'jwt');
```

### Wallet Security
- Private keys encrypted with user passwords
- Wallet addresses validated before storage
- Secure key derivation for blockchain operations

## AI Integration Patterns

### Career Advice System
Multi-step workflow with state management:
```dart
class CareerAdviceMain extends StatefulWidget {
  // Manages step navigation and data collection
  // Steps: Welcome → CV Check → Goals → Skills → Industry → Results
}
```

### Request/Response Models
```dart
class CareerAdviceRequest {
  String? careerGoal;
  Map<String, int>? skillRatings;
  List<String>? selectedIndustries;
  bool? cvCompleted;
}
```

## Development Guidelines

### When Adding New Features:
1. **Create BLL interface first**: Define business logic contract
2. **Implement service layer**: Handle data access and API calls
3. **Add model classes**: Include proper JSON serialization
4. **Create responsive UI**: Support both mobile and desktop
5. **Add route registration**: Update main.dart routes
6. **Implement error handling**: Use consistent error patterns

### When Working with Blockchain:
1. **Validate wallet addresses**: Use `isWalletAddressValid()` pattern
2. **Handle async operations**: All blockchain calls are async
3. **Store sensitive data securely**: Use FlutterSecureStorage
4. **Implement retry logic**: Network operations can fail

### When Adding UI Components:
1. **Follow responsive patterns**: Use breakpoint-based layouts
2. **Use consistent styling**: Google Fonts and color schemes
3. **Implement loading states**: FutureBuilder with proper state handling
4. **Add error boundaries**: Handle network and data errors gracefully

### Configuration Updates:
- **API endpoints**: Update `BackenConnection.dart`
- **Blockchain networks**: Modify `EtheriumConnection.dart`
- **IPFS settings**: Adjust `IPFSConnection.dart`

## Common Code Patterns to Follow

### Service Initialization
```dart
final IUserBLL _userBll = UserBll();
final IBlockchainWalletBll _blockchainWalletBll = BlockchainWalletBll();
```

### Async Data Loading
```dart
late Future<List<DataType>> _dataFuture;

@override
void initState() {
  super.initState();
  _dataFuture = _loadData();
}
```

### Form Validation
```dart
if (email.isEmpty || password.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please fill in all fields')),
  );
  return;
}
```

This architecture ensures maintainable, scalable code while leveraging Flutter's strengths and integrating complex blockchain and AI functionality seamlessly.
