enum ProfileDocumentTitles {
  drivingLicense,
  businessLicense,
  accountingCertificate,
  taxCertificate,
  accountManagementCertificate,
  bankAccountDetails,
}

extension IndextedDocument on ProfileDocumentTitles {
  int get index {
    switch (this) {
      case ProfileDocumentTitles.drivingLicense:
        return 0;
      case ProfileDocumentTitles.businessLicense:
        return 1;
      case ProfileDocumentTitles.accountingCertificate:
        return 2;
      case ProfileDocumentTitles.taxCertificate:
        return 3;
      case ProfileDocumentTitles.accountManagementCertificate:
        return 4;
      case ProfileDocumentTitles.bankAccountDetails:
        return 5;
      default:
        return -1;
    }
  }

  String? get title {
    switch (this) {
      case ProfileDocumentTitles.drivingLicense:
        return "رخصة قيادة";
      case ProfileDocumentTitles.businessLicense:
        return "شهادة مصلحة / شهادة صاحب مصلحة مرخصة";
      case ProfileDocumentTitles.accountingCertificate:
        return "شهادة إدارة دفاتر الحسابات";
      case ProfileDocumentTitles.taxCertificate:
        return "شهادة خصم ضريبة عند المصدر";
      case ProfileDocumentTitles.accountManagementCertificate:
        return "شهادة إدارة حساب";
      case ProfileDocumentTitles.bankAccountDetails:
        return "تفاصيل الحساب البنكي";
      default:
        return null;
    }
  }

  String? get key {
    switch (this) {
      case ProfileDocumentTitles.drivingLicense:
        return "drivingLicense";
      case ProfileDocumentTitles.businessLicense:
        return "businessLicense";
      case ProfileDocumentTitles.accountingCertificate:
        return "accountingCertificate";
      case ProfileDocumentTitles.taxCertificate:
        return "taxCertificate";
      case ProfileDocumentTitles.accountManagementCertificate:
        return "accountManagementCertificate";
      case ProfileDocumentTitles.bankAccountDetails:
        return "bankAccountDetails";
      default:
        return null;
    }
  }
}
