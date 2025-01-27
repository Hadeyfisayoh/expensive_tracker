# **Expense Tracker**

An intuitive and user-friendly Flutter application designed to help users manage their expenses effectively. This app enables users to track their spending habits, categorize expenses, and visualize their financial data conveniently.

---

## **App Features**

- **User Authentication:** Secure login and registration using Firebase Authentication.
- **Expense Management:** Add, view, and manage expenses categorized by type.
- **Data Synchronization:** Stores and syncs user data with Firebase Firestore for real-time access.
- **Intuitive UI/UX:** A clean and simple interface optimized for user experience.
- **Multi-Device Support:** Access your data seamlessly across multiple devices.

---

## **App Architecture and Patterns**

The app follows the **MVVM (Model-View-ViewModel)** pattern to ensure clean separation of concerns and maintainability.

- **Models:** Represent data structures like `Expense` for managing expense details.
- **View:** UI components built with Flutter widgets for smooth navigation and responsiveness.
- **ViewModel:** Handles logic and interaction between the UI and the data layer.
- **Services:** Firebase services for authentication and Firestore for database interaction.

---

## **Tools and Libraries Used**

- **Flutter:** A UI toolkit for building natively compiled mobile applications.
- **Firebase Authentication:** To handle user login and registration.
- **Firebase Firestore:** A NoSQL cloud database for real-time data storage and synchronization.
- **Provider:** State management for seamless data flow across the app.
- **Google Fonts:** For custom font styles.
- **Intl Package:** To format dates and currencies appropriately.

---

## **Setup and Installation**

### **Requirements**
- Flutter SDK
- Dart SDK
- Firebase Account

### **Steps**
1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/expense_tracker.git
   cd expense_tracker
