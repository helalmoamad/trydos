class CustomerWalletModel {
  final bool isSuccessful;
  final bool hasContent;
  final int code;
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
        isSuccessful: json["isSuccessful"],
        hasContent: json["hasContent"],
        code: json["code"],
        message: json["message"],
        detailedError: json["detailed_error"],
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
  final int limit;
  final int offset;
  final int totalWalletBalance;
  final String totalWalletBalanceFormatted;
  final int totalWalletTransaction;
  final List<WalletTransactionList> walletTransactionList;

  CustomerWalletDataModel({
    required this.limit,
    required this.offset,
    required this.totalWalletBalance,
    required this.totalWalletBalanceFormatted,
    required this.totalWalletTransaction,
    required this.walletTransactionList,
  });

  CustomerWalletDataModel copyWith({
    int? limit,
    int? offset,
    int? totalWalletBalance,
    String? totalWalletBalanceFormatted,
    int? totalWalletTransaction,
    List<WalletTransactionList>? walletTransactionList,
  }) =>
      CustomerWalletDataModel(
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        totalWalletBalance: totalWalletBalance ?? this.totalWalletBalance,
        totalWalletBalanceFormatted:
            totalWalletBalanceFormatted ?? this.totalWalletBalanceFormatted,
        totalWalletTransaction:
            totalWalletTransaction ?? this.totalWalletTransaction,
        walletTransactionList:
            walletTransactionList ?? this.walletTransactionList,
      );

  factory CustomerWalletDataModel.fromJson(Map<String, dynamic> json) =>
      CustomerWalletDataModel(
        limit: json["limit"],
        offset: json["offset"],
        totalWalletBalance: json["total_wallet_balance"],
        totalWalletBalanceFormatted: json["total_wallet_balance_formatted"],
        totalWalletTransaction: json["total_wallet_transaction"],
        walletTransactionList: List<WalletTransactionList>.from(
            json["wallet_transaction_list"]
                .map((x) => WalletTransactionList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "limit": limit,
        "offset": offset,
        "total_wallet_balance": totalWalletBalance,
        "total_wallet_balance_formatted": totalWalletBalanceFormatted,
        "total_wallet_transaction": totalWalletTransaction,
        "wallet_transaction_list":
            List<dynamic>.from(walletTransactionList.map((x) => x.toJson())),
      };
}

class WalletTransactionList {
  final int id;
  final int userId;
  final dynamic orderId;
  final int transactionId;
  final int credit;
  final int debit;
  final int adminBonus;
  final int balance;
  final String transactionType;
  final String reference;
  final dynamic paymentMethodCustomer;
  final int returnedToCreditCart;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;
  final dynamic returnRequestId;
  final dynamic destinationId;
  final dynamic convertedWalletTransactionId;
  final String statusPayment;
  final String creditFormatted;
  final String debitFormatted;
  final String balanceFormatted;
  final String destinationName;

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
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.returnRequestId,
    required this.destinationId,
    required this.convertedWalletTransactionId,
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
    int? credit,
    int? debit,
    int? adminBonus,
    int? balance,
    String? transactionType,
    String? reference,
    dynamic paymentMethodCustomer,
    int? returnedToCreditCart,
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
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        returnRequestId: returnRequestId ?? this.returnRequestId,
        destinationId: destinationId ?? this.destinationId,
        convertedWalletTransactionId:
            convertedWalletTransactionId ?? this.convertedWalletTransactionId,
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
        transactionId: json["transaction_id"],
        credit: json["credit"],
        debit: json["debit"],
        adminBonus: json["admin_bonus"],
        balance: json["balance"],
        transactionType: json["transaction_type"],
        reference: json["reference"],
        paymentMethodCustomer: json["payment_method_customer"],
        returnedToCreditCart: json["returned_to_credit_cart"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        returnRequestId: json["return_request_id"],
        destinationId: json["destination_id"],
        convertedWalletTransactionId: json["converted_wallet_transaction_id"],
        statusPayment: json["status_payment"],
        creditFormatted: json["credit_formatted"],
        debitFormatted: json["debit_formatted"],
        balanceFormatted: json["balance_formatted"],
        destinationName: json["destination_name"],
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
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "return_request_id": returnRequestId,
        "destination_id": destinationId,
        "converted_wallet_transaction_id": convertedWalletTransactionId,
        "status_payment": statusPayment,
        "credit_formatted": creditFormatted,
        "debit_formatted": debitFormatted,
        "balance_formatted": balanceFormatted,
        "destination_name": destinationName,
      };
}
