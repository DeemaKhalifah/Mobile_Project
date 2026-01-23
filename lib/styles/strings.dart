/// Centralized UI Strings for the Car Wash Application
/// This file contains all hardcoded strings used across the application UI
class AppStrings {
  // ==================== Common/General ====================
  static const String done = "Done";
  static const String cancel = "Cancel";
  static const String delete = "Delete";
  static const String edit = "Edit";
  static const String logout = "Logout";
  static const String noDataFound = "No data found";
  static const String loading = "Loading...";
  static const String error = "Error";
  static const String success = "Success";

  // ==================== Welcome Screen ====================
  static const String welcomeTitle = "Welcome to Car Wash App";
  static const String customer = "Customer";
  static const String employee = "Employee";
  static const String manager = "Manager";

  // ==================== Login Screen ====================
  static const String loginTitle = "Login";
  static const String email = "Email";
  static const String password = "Password";
  static const String enterEmail = "Enter email";
  static const String enterPassword = "Enter password";
  static const String forgotPassword = "Forgot Password?";
  static const String login = "Login";
  static const String noAccount = "Don't have an account? ";
  static const String signUp = "Sign Up";
  static const String role = "Role";

  // ==================== Signup Screen ====================
  static const String signUpTitle = "Sign Up";
  static const String name = "Name";
  static const String pleaseEnterName = "Please enter your name";
  static const String pleaseEnterEmail = "Please enter your email";
  static const String pleaseEnterPassword = "Please enter your password";
  static const String phone = "Phone";
  static const String createAccount = "Create Account";
  static const String roleLabel = "Role";

  // ==================== Booking Form ====================
  static const String bookingFormTitle = "Booking Form";
  static const String location = "Location";
  static const String notes = "Notes";
  static const String date = "Date";
  static const String time = "Time";
  static const String carModel = "Car Model";
  static const String carPlate = "Car Plate";
  static const String enterLocation = "Enter location";
  static const String selectDate = "Select date";
  static const String selectTime = "Select time";
  static const String enterCarModel = "Enter car model";
  static const String enterPlateNumber = "Enter plate number";
  static const String invalidPlate = "Invalid plate (6-8 letters/numbers)";
  static const String bookService = "Book Service";
  static const String updateBooking = "Update Booking";
  static const String confirmBooking = "Confirm Booking";

  // ==================== Service Screens ====================
  static const String services = "Services";
  static const String serviceDetails = "Service Details";
  static const String price = "Price";
  static const String noServicesFound = "No services found";
  static const String description = "Description";
  static const String noDescription = "No description";
  static const String viewDetails = "View Details";
  static const String selectService = "Select a service";

  // ==================== Payment Screen ====================
  static const String payment = "Payment";
  static const String cardNumber = "Card Number";
  static const String cardHolderName = "Card Holder Name";
  static const String expiryDate = "Expiry Date";
  static const String cvv = "CVV";
  static const String totalAmount = "Total Amount";
  static const String proceedPayment = "Proceed to Payment";

  // ==================== Wallet Screen ====================
  static const String wallet = "Wallet";
  static const String balance = "Balance";
  static const String walletSummary = "Wallet Summary";
  static const String addMoney = "Add Money";
  static const String currentBalance = "Current Balance";
  static const String recentTransactions = "Recent Transactions";
  static const String noTransactions = "No transactions";

  // ==================== Orders Screen ====================
  static const String orders = "Orders";
  static const String employeeOrders = "Employee Orders";
  static const String currentServices = "Current Services";
  static const String orderDetails = "Order Details";
  static const String orderID = "Order ID";
  static const String status = "Status";
  static const String filterByStatus = "Filter by status";
  static const String noOrders = "No orders found";
  static const String update = "Update";
  static const String cancelOrder = "Cancel";
  static const String assigned = "Assigned";
  static const String inProgress = "In Progress";
  static const String completed = "Completed";
  static const String cancelled = "Cancelled";

  // ==================== Feedback Screen ====================
  static const String feedback = "Feedback";
  static const String managerFeedback = "Manager Feedback";
  static const String leaveFeedback = "Leave Feedback";
  static const String rating = "Rating";
  static const String message = "Message";
  static const String submit = "Submit";
  static const String noFeedback = "No feedback yet";

  // ==================== Teams Screen ====================
  static const String teams = "Teams";
  static const String teamDetails = "Team Details";
  static const String teamName = "Team Name";
  static const String leaderEmployee = "Leader Employee";
  static const String carNumberPlate = "Car Number Plate";
  static const String teamMembers = "Team Members";
  static const String addEmployee = "Add Employee";
  static const String addToTeam = "Add to Team";
  static const String teamIsFull = "Team is full (4)";
  static const String noAvailableEmployees =
      "No available employees (all employees already assigned).";
  static const String noMembersInTeam = "No members in this team yet.";
  static const String saving = "Saving...";
  static const String pleaseWait = "Please wait...";

  // ==================== Navigation & Profile ====================
  static const String home = "Home";
  static const String profile = "Profile";
  static const String profileTitle = "User Profile";
  static const String emailLabel = "Email";
  static const String roleDescription = "Role";
  static const String changeStatus = "Change status";

  // ==================== Validation Messages ====================
  static const String fieldRequired = "This field is required";
  static const String invalidEmail = "Invalid email address";
  static const String passwordTooShort =
      "Password must be at least 6 characters";
  static const String enterValidNamePrice = "Enter valid name & price";

  // ==================== Service Management ====================
  static const String addService = "Add Service";
  static const String serviceName = "Service Name";
  static const String servicePrice = "Service Price";
  static const String serviceImage = "Service Image";
  static const String pickImage = "Pick Image";
  static const String removeImage = "Remove";
  static const String noImageSelected = "No image selected";
  static const String currentImage = "Current";
  static const String descriptionOptional = "Description (optional)";
  static const String unnamed = "Unnamed Service";
  static const String unnamedTeam = "Team";
  static const String unnamedEmployee = "Employee";

  // ==================== Dialogs & Messages ====================
  static const String confirmDelete = "Confirm Delete";
  static const String deleteConfirmation =
      "Are you sure you want to delete this?";
  static const String deleteSuccess = "Deleted successfully";
  static const String savingData = "Saving data...";
  static const String loadingData = "Loading data...";
  static const String errorOccurred = "An error occurred";
  static const String tryAgain = "Try Again";
  static const String networkError = "Network error";
  static const String serverError = "Server error";

  // ==================== Button Labels ====================
  static const String submit_button = "Submit";
  static const String save = "Save";
  static const String search = "Search";
  static const String refresh = "Refresh";
  static const String back = "Back";
  static const String next = "Next";
  static const String previous = "Previous";
  static const String ok = "OK";

  // ==================== Status Text ====================
  static const String pending = "Pending";
  static const String active = "Active";
  static const String inactive = "Inactive";
  static const String available = "Available";
  static const String unavailable = "Unavailable";

  // ==================== Info Text ====================
  static const String carPlateInfo = "Car Plate";
  static const String serviceNameInfo = "Service Name";
  static const String priceInfo = "Price";
  static const String locationInfo = "Location";
  static const String notesInfo = "Notes";
  static const String dateInfo = "Date";
  static const String timeInfo = "Time";
  static const String customerEmailInfo = "Customer Email";
}
