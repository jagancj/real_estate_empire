import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'dart:math';

class Loan {
  final String id;
  final String bankName;
  final double originalAmount;
  double remainingAmount;
  final double interestRate;
  final int totalMonths;
  int remainingMonths;
  final double monthlyPayment;
  final DateTime startDate;
  DateTime dueDate;
  
  Loan({
    required this.id,
    required this.bankName,
    required this.originalAmount,
    required this.remainingAmount,
    required this.interestRate,
    required this.totalMonths,
    required this.remainingMonths,
    required this.monthlyPayment,
    required this.startDate,
    required this.dueDate,
  });
  
  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      bankName: json['bankName'],
      originalAmount: json['originalAmount'],
      remainingAmount: json['remainingAmount'],
      interestRate: json['interestRate'],
      totalMonths: json['totalMonths'],
      remainingMonths: json['remainingMonths'],
      monthlyPayment: json['monthlyPayment'],
      startDate: DateTime.parse(json['startDate']),
      dueDate: DateTime.parse(json['dueDate']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'originalAmount': originalAmount,
      'remainingAmount': remainingAmount,
      'interestRate': interestRate,
      'totalMonths': totalMonths,
      'remainingMonths': remainingMonths,
      'monthlyPayment': monthlyPayment,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }
  
  // Make a payment
  double makePayment() {
    if (remainingAmount <= 0 || remainingMonths <= 0) {
      return 0;
    }
    
    if (remainingAmount <= monthlyPayment) {
      // Last payment
      final payment = remainingAmount;
      remainingAmount = 0;
      remainingMonths = 0;
      return payment;
    }
    
    remainingAmount -= monthlyPayment;
    remainingMonths--;
    return monthlyPayment;
  }
  
  // Make an early payment
  double makeEarlyPayment(double amount) {
    if (remainingAmount <= 0) {
      return 0;
    }
    
    if (amount >= remainingAmount) {
      // Pay off the loan
      final payment = remainingAmount;
      remainingAmount = 0;
      remainingMonths = 0;
      return payment;
    }
    
    remainingAmount -= amount;
    // Recalculate remaining months
    remainingMonths = (remainingAmount / monthlyPayment).ceil();
    return amount;
  }

  // Check if loan is paid off
  bool get isPaidOff => remainingAmount <= 0;
  
  // Get progress percentage
  double get progressPercentage => 1 - (remainingAmount / originalAmount);
  
  // Calculate total cost of loan
  double get totalCost => monthlyPayment * totalMonths;
  
  // Calculate total interest
  double get totalInterest => totalCost - originalAmount;
}

class Bank {
  final String id;
  final String name;
  final IconData logo;
  final Color color;
  final double maxLoanAmount;
  final double interestRate;
  final int term; // months
  
  Bank({
    required this.id,
    required this.name,
    required this.logo,
    required this.color,
    required this.maxLoanAmount,
    required this.interestRate,
    required this.term,
  });

  // Calculate monthly payment for a loan
  double calculateMonthlyPayment(double principal) {
    final monthlyRate = interestRate / 100 / 12;
    return principal * monthlyRate * (pow(1 + monthlyRate, term) / (pow(1 + monthlyRate, term) - 1));
  }
}

class LoanProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<Loan> _loans = [];
  List<Bank> _banks = [];
  bool _isInitialized = false;
  
  LoanProvider(this._databaseService) {
    _initializeData();
  }
  
  // Getters
  List<Loan> get loans => _loans;
  List<Bank> get banks => _banks;
  bool get isInitialized => _isInitialized;
  
  // Get total debt
  double get totalDebt {
    double total = 0;
    for (var loan in _loans) {
      total += loan.remainingAmount;
    }
    return total;
  }
  
  // Get total monthly payment
  double get totalMonthlyPayment {
    double total = 0;
    for (var loan in _loans) {
      total += loan.monthlyPayment;
    }
    return total;
  }
  
  // Initialize data
  Future<void> _initializeData() async {
    await _loadLoans();
    _initializeBanks();
    _isInitialized = true;
    notifyListeners();
  }
  
  // Load loans from database
  Future<void> _loadLoans() async {
    try {
      final loansData = await _databaseService.getLoans();
      _loans = loansData.map((data) => Loan.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error loading loans: $e');
      _loans = [];
    }
  }
  
  // Initialize available banks
  void _initializeBanks() {
    _banks = [
      Bank(
        id: 'first_national',
        name: 'First National Bank',
        logo: Icons.account_balance,
        color: Colors.blue,
        maxLoanAmount: 100000.0,
        interestRate: 5.0,
        term: 12,
      ),
      Bank(
        id: 'central_investment',
        name: 'Central Investment',
        logo: Icons.business,
        color: Colors.purple,
        maxLoanAmount: 250000.0,
        interestRate: 7.5,
        term: 24,
      ),
      Bank(
        id: 'fortune_finance',
        name: 'Fortune Finance',
        logo: Icons.attach_money,
        color: Colors.green,
        maxLoanAmount: 500000.0,
        interestRate: 10.0,
        term: 36,
      ),
    ];
  }
  
  // Create a new loan
  Future<bool> createLoan(String bankId, double amount) async {
    try {
      // Find the bank
      final bank = _banks.firstWhere((b) => b.id == bankId);
      
      // Check if amount is valid
      if (amount <= 0 || amount > bank.maxLoanAmount) {
        return false;
      }
      
      // Calculate monthly payment
      final monthlyPayment = bank.calculateMonthlyPayment(amount);
      
      // Create new loan
      final loan = Loan(
        id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
        bankName: bank.name,
        originalAmount: amount,
        remainingAmount: amount,
        interestRate: bank.interestRate,
        totalMonths: bank.term,
        remainingMonths: bank.term,
        monthlyPayment: monthlyPayment,
        startDate: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: 30)), // Next payment due in 30 days
      );
      
      // Add to list
      _loans.add(loan);
      
      // Save to database
      await _databaseService.saveLoan(loan.toJson());
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating loan: $e');
      return false;
    }
  }
  
  // Make a payment for a loan
  Future<bool> makePayment(String loanId) async {
    try {
      // Find the loan
      final loanIndex = _loans.indexWhere((l) => l.id == loanId);
      if (loanIndex == -1) {
        return false;
      }
      
      final loan = _loans[loanIndex];
      final payment = loan.makePayment();
      
      if (payment <= 0) {
        return false;
      }
      
      // If loan is paid off, remove it from the list
      if (loan.isPaidOff) {
        _loans.removeAt(loanIndex);
        await _databaseService.deleteLoan(loanId);
      } else {
        // Update the loan in the database
        await _databaseService.saveLoan(loan.toJson());
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error making payment: $e');
      return false;
    }
  }
  
  // Make an early payment for a loan
  Future<bool> makeEarlyPayment(String loanId, double amount) async {
    try {
      // Find the loan
      final loanIndex = _loans.indexWhere((l) => l.id == loanId);
      if (loanIndex == -1) {
        return false;
      }
      
      final loan = _loans[loanIndex];
      final payment = loan.makeEarlyPayment(amount);
      
      if (payment <= 0) {
        return false;
      }
      
      // If loan is paid off, remove it from the list
      if (loan.isPaidOff) {
        _loans.removeAt(loanIndex);
        await _databaseService.deleteLoan(loanId);
      } else {
        // Update the loan in the database
        await _databaseService.saveLoan(loan.toJson());
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error making early payment: $e');
      return false;
    }
  }
  
  // Process monthly payments for all active loans
  Future<double> processMonthlyPayments() async {
    double totalPayments = 0;
    
    // Create a copy of the list since we might be removing items
    final loansList = List<Loan>.from(_loans);
    
    for (var loan in loansList) {
      // Check if payment is due
      if (DateTime.now().isAfter(loan.dueDate)) {
        final payment = loan.makePayment();
        totalPayments += payment;
        
        // Update due date for next month
        final nextDueDate = loan.dueDate.add(const Duration(days: 30));
        loan.dueDate = nextDueDate;
        
        // If loan is paid off, remove it
        if (loan.isPaidOff) {
          _loans.remove(loan);
          await _databaseService.deleteLoan(loan.id);
        } else {
          // Update the loan in the database
          await _databaseService.saveLoan(loan.toJson());
        }
      }
    }
    
    if (totalPayments > 0) {
      notifyListeners();
    }
    
    return totalPayments;
  }
  
  // Get a specific bank
  Bank? getBank(String bankId) {
    try {
      return _banks.firstWhere((b) => b.id == bankId);
    } catch (e) {
      return null;
    }
  }
  
  // Calculate max loan amount based on player's net worth
  double getMaxLoanAmount(String bankId, double netWorth) {
    try {
      final bank = _banks.firstWhere((b) => b.id == bankId);
      // Player can borrow up to 70% of their net worth
      final playerMaxAmount = netWorth * 0.7;
      // Return the lower of the two limits
      return playerMaxAmount < bank.maxLoanAmount ? playerMaxAmount : bank.maxLoanAmount;
    } catch (e) {
      return 0;
    }
  }
  
  // Calculate debt-to-income ratio
  double calculateDebtToIncomeRatio(double dailyIncome) {
    if (dailyIncome <= 0) return 0;
    
    // Convert daily income to monthly
    final monthlyIncome = dailyIncome * 30;
    
    // Calculate ratio
    return (totalMonthlyPayment / monthlyIncome) * 100;
  }
}