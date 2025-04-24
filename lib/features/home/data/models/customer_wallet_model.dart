class CustomerWalletModel {
  final bool? isSuccessful;
  final bool? hasContent;
  final int? code;
  final String message;
  final dynamic detailedError;
  final CustomerWalletDataModel data;

  CustomerWalletModel({
    required this.isSuccessful,
    required this.hasContent,
    required this.code,
    required this.message,
    required this.detailedError,
    required this.data,
  });

  CustomerWalletModel copyWith({
    bool? isSuccessful,
    bool? hasContent,
    int? code,
    String? message,
    dynamic detailedError,
    CustomerWalletDataModel? data,
  }) =>
      CustomerWalletModel(
        isSuccessful: isSuccessful ?? this.isSuccessful,
        hasContent: hasContent ?? this.hasContent,
        code: code ?? this.code,
        message: message ?? this.message,
        detailedError: detailedError ?? this.detailedError,
        data: data ?? this.data,
      );

  factory CustomerWalletModel.fromJson(Map<String, dynamic> json) =>
      CustomerWalletModel(
        isSuccessful: json["isSuccessful"] ?? false,
        hasContent: json["hasContent"] ?? false,
        code: json["code"] ?? 0,
        message: json["message"] ?? '',
        detailedError: json["detailed_error"] ?? '',
        data: CustomerWalletDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "isSuccessful": isSuccessful,
        "hasContent": hasContent,
        "code": code,
        "message": message,
        "detailed_error": detailedError,
        "data": data.toJson(),
      };
}

class CustomerWalletDataModel {
  final int? limit;
  final int? offset;
  final double? totalWalletBalance;
  final String? currencySymbol;
  final String? currencyCode;
  final int? totalWalletTransaction;
  final List<WalletTransactionList> walletTransactionList;

  CustomerWalletDataModel({
    required this.limit,
    required this.offset,
    required this.totalWalletBalance,
    required this.currencySymbol,
    required this.currencyCode,
    required this.totalWalletTransaction,
    required this.walletTransactionList,
  });

  CustomerWalletDataModel copyWith({
    int? limit,
    int? offset,
    double? totalWalletBalance,
    String? totalWalletBalanceFormatted,
    String? currencySymbol,
    String? currencyCode,
    int? totalWalletTransaction,
    List<WalletTransactionList>? walletTransactionList,
  }) =>
      CustomerWalletDataModel(
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        totalWalletBalance: totalWalletBalance ?? this.totalWalletBalance,
        currencyCode: currencyCode ?? this.currencyCode,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        totalWalletTransaction:
            totalWalletTransaction ?? this.totalWalletTransaction,
        walletTransactionList:
            walletTransactionList ?? this.walletTransactionList,
      );

  factory CustomerWalletDataModel.fromJson(Map<String, dynamic> json) =>
      CustomerWalletDataModel(
        limit: json["limit"] ?? 0,
        offset: json["offset"] ?? 0,
        totalWalletBalance: json["wallet_balance"] == null
            ? 0
            : double.parse(
                json["wallet_balance"].toString(),
              ),
        totalWalletTransaction: json["total_wallet_transaction"] ?? 0,
        currencyCode: json["currency_code"] ?? '',
        currencySymbol: json["currency_symbol"] ?? '',
        walletTransactionList: [],
        // List<WalletTransactionList>.from(
        //     json["wallet_transaction_list"]
        //         .map((x) => WalletTransactionList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "limit": limit,
        "offset": offset,
        "total_wallet_balance": totalWalletBalance,
        "currency_code": currencyCode,
        "currency_symbol": currencySymbol,
        "wallet_balance": totalWalletTransaction,
        "wallet_transaction_list":
            List<dynamic>.from(walletTransactionList.map((x) => x.toJson())),
      };
}

class WalletTransactionList {
  final int id;
  final int userId;
  final dynamic orderId;
  final int? transactionId;
  final double? credit;
  final double? debit;
  final double? adminBonus;
  final double? balance;
  final String? transactionType;
  final String? reference;
  final dynamic paymentMethodCustomer;
  final double? returnedToCreditCart;
  final String? statusPayment;
  final String? creditFormatted;
  final String? debitFormatted;
  final String? balanceFormatted;
  final String? destinationName;

  WalletTransactionList({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.transactionId,
    required this.credit,
    required this.debit,
    required this.adminBonus,
    required this.balance,
    required this.transactionType,
    required this.reference,
    required this.paymentMethodCustomer,
    required this.returnedToCreditCart,
    required this.statusPayment,
    required this.creditFormatted,
    required this.debitFormatted,
    required this.balanceFormatted,
    required this.destinationName,
  });

  WalletTransactionList copyWith({
    int? id,
    int? userId,
    dynamic orderId,
    int? transactionId,
    double? credit,
    double? debit,
    double? adminBonus,
    double? balance,
    String? transactionType,
    String? reference,
    dynamic paymentMethodCustomer,
    double? returnedToCreditCart,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    dynamic returnRequestId,
    dynamic destinationId,
    dynamic convertedWalletTransactionId,
    String? statusPayment,
    String? creditFormatted,
    String? debitFormatted,
    String? balanceFormatted,
    String? destinationName,
  }) =>
      WalletTransactionList(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        orderId: orderId ?? this.orderId,
        transactionId: transactionId ?? this.transactionId,
        credit: credit ?? this.credit,
        debit: debit ?? this.debit,
        adminBonus: adminBonus ?? this.adminBonus,
        balance: balance ?? this.balance,
        transactionType: transactionType ?? this.transactionType,
        reference: reference ?? this.reference,
        paymentMethodCustomer:
            paymentMethodCustomer ?? this.paymentMethodCustomer,
        returnedToCreditCart: returnedToCreditCart ?? this.returnedToCreditCart,
        statusPayment: statusPayment ?? this.statusPayment,
        creditFormatted: creditFormatted ?? this.creditFormatted,
        debitFormatted: debitFormatted ?? this.debitFormatted,
        balanceFormatted: balanceFormatted ?? this.balanceFormatted,
        destinationName: destinationName ?? this.destinationName,
      );

  factory WalletTransactionList.fromJson(Map<String, dynamic> json) =>
      WalletTransactionList(
        id: json["id"],
        userId: json["user_id"],
        orderId: json["order_id"],
        transactionId: json["transaction_id"] ?? 0,
        credit: json["credit"] == null
            ? 0
            : double.parse(json["credit"].toString()),
        debit:
            json["debit"] == null ? 0 : double.parse(json["debit"].toString()),
        adminBonus: json["admin_bonus"] == null
            ? 0
            : double.parse(json["admin_bonus"].toString()),
        balance: json["balance"] == null
            ? 0
            : double.parse(json["balance"].toString()),
        transactionType: json["transaction_type"] ?? '',
        reference: json["reference"] ?? '',
        paymentMethodCustomer: json["payment_method_customer"],
        returnedToCreditCart: json["returned_to_credit_cart"] == null
            ? 0
            : double.parse(json["returned_to_credit_cart"].toString()),
        statusPayment: json["status_payment"] ?? '',
        creditFormatted: json["credit_formatted"] ?? '',
        debitFormatted: json["debit_formatted"] ?? '',
        balanceFormatted: json["balance_formatted"] ?? '',
        destinationName: json["destination_name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "order_id": orderId,
        "transaction_id": transactionId,
        "credit": credit,
        "debit": debit,
        "admin_bonus": adminBonus,
        "balance": balance,
        "transaction_type": transactionType,
        "reference": reference,
        "payment_method_customer": paymentMethodCustomer,
        "returned_to_credit_cart": returnedToCreditCart,
        "status_payment": statusPayment,
        "credit_formatted": creditFormatted,
        "debit_formatted": debitFormatted,
        "balance_formatted": balanceFormatted,
        "destination_name": destinationName,
      };
}
