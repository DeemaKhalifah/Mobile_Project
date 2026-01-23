# 🚀 Quick Reference - Using Centralized Strings

## The Basics

### 1. Import Strings
```dart
import '../styles/strings.dart';  // For screens in lib/screens/
import '../../styles/strings.dart'; // For screens in nested folders
```

### 2. Use AppStrings Constants
```dart
// Instead of:
Text("Login")

// Do this:
Text(AppStrings.login)
```

## Common String Usage Examples

### Labels & Headers
```dart
AppBar(title: Text(AppStrings.loginTitle))
Text(AppStrings.email)
Text(AppStrings.password)
```

### Input Fields
```dart
TextField(
  decoration: InputDecoration(
    labelText: AppStrings.name,
  ),
)
```

### Validation
```dart
validator: (val) => val?.isEmpty 
  ? AppStrings.fieldRequired 
  : null
```

### Buttons
```dart
ElevatedButton(
  child: const Text(AppStrings.login),
  onPressed: () {},
)
```

### SnackBars
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(AppStrings.success)),
)
```

## Available String Categories

### Authentication
- `loginTitle`, `signUpTitle`, `email`, `password`, `name`, `phone`
- `enterEmail`, `enterPassword`, `pleaseEnterName`

### Forms
- `location`, `notes`, `date`, `time`, `carModel`, `carPlate`
- `selectDate`, `selectTime`, `enterLocation`

### Services
- `bookService`, `viewDetails`, `services`, `serviceDetails`
- `serviceName`, `price`, `description`

### Wallet & Payment
- `wallet`, `payment`, `balance`, `addMoney`
- `cardNumber`, `cardHolderName`, `expiryDate`, `cvv`

### Orders
- `orders`, `employeeOrders`, `currentServices`
- `filterByStatus`, `assigned`, `completed`, `cancelled`

### Teams
- `teams`, `teamName`, `teamMembers`, `addEmployee`

### General
- `done`, `cancel`, `delete`, `edit`, `logout`
- `profile`, `role`, `feedback`, `loading`, `error`

## Adding New Strings

### Step 1: Open strings.dart
```
lib/styles/strings.dart
```

### Step 2: Add Your String
```dart
// Find the right category or create one
// ==================== My Category ====================
static const String myString = "My String Text";
```

### Step 3: Use in Your Screen
```dart
Text(AppStrings.myString)
```

## Pro Tips

### ✅ DO
- Use consistent string variable names
- Group related strings in categories
- Use descriptive constant names
- Add comments for categories

### ❌ DON'T
- Don't mix centralized and hardcoded strings
- Don't create duplicate constants
- Don't use magic numbers with strings
- Don't forget the `static const` modifier

## Troubleshooting

### Import Error
```
Error: 'strings' is not exported from 'app_styles.dart'
```
**Solution**: Make sure you're importing `strings.dart`, not `app_styles.dart`

### Undefined Reference
```
Error: Undefined name 'AppStrings'
```
**Solution**: Add the import at the top of your file

### Missing Constant
```
Error: 'login' is not defined
```
**Solution**: Check the exact constant name (case-sensitive)

## File Structure
```
lib/
├── styles/
│   ├── app_styles.dart      (Colors, fonts, button styles)
│   └── strings.dart         (All UI text strings) ← YOU ARE HERE
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── ... (all other screens)
└── models/
    ├── user.dart
    └── ...
```

## Real-World Example

### Before (Hardcoded)
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(decoration: InputDecoration(labelText: "Email")),
          TextField(decoration: InputDecoration(labelText: "Password")),
          ElevatedButton(child: Text("Login"), onPressed: () {}),
        ],
      ),
    );
  }
}
```

### After (Centralized)
```dart
import '../styles/strings.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.loginTitle)),
      body: Column(
        children: [
          TextField(decoration: InputDecoration(labelText: AppStrings.email)),
          TextField(decoration: InputDecoration(labelText: AppStrings.password)),
          ElevatedButton(child: Text(AppStrings.login), onPressed: () {}),
        ],
      ),
    );
  }
}
```

## String List by Screen

### Login Screen
- loginTitle, email, password, enterEmail, enterPassword
- forgotPassword, login, noAccount, signUp

### Signup Screen
- signUpTitle, name, email, password, phone
- pleaseEnterName, pleaseEnterEmail, pleaseEnterPassword
- roleLabel, createAccount

### Customer Main
- services, viewDetails, price

### Booking Form
- location, notes, date, time, carModel, carPlate
- selectDate, selectTime, enterLocation, enterCarModel
- enterPlateNumber, invalidPlate

### Wallet
- wallet, balance, addMoney, cardNumber, cardHolderName
- expiryDate, cvv

### Orders
- orders, employeeOrders, filterByStatus
- assigned, inProgress, completed, cancelled

### Manager Screens
- services, teams, orders, feedback
- teamName, addEmployee, leaderEmployee

---

**Happy coding!** 🎉

For complete list of strings, see `lib/styles/strings.dart`
