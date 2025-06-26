enum ProfileDocumentTitles {
  documentTitle1,
  documentTitle2,
  documentTitle3,
  documentTitle4,
  documentTitle5,
}

extension IndextedDocument on ProfileDocumentTitles {
  int get index {
    switch (this) {
      case ProfileDocumentTitles.documentTitle1:
        return 0;
      case ProfileDocumentTitles.documentTitle2:
        return 1;
      case ProfileDocumentTitles.documentTitle3:
        return 2;
      case ProfileDocumentTitles.documentTitle4:
        return 3;
      case ProfileDocumentTitles.documentTitle5:
        return 4;
      default:
        return -1;
    }
  }

  String? get title {
    switch (this) {
      case ProfileDocumentTitles.documentTitle1:
        return "Document 1";
      case ProfileDocumentTitles.documentTitle2:
        return "Document 2";
      case ProfileDocumentTitles.documentTitle3:
        return "Document 3";
      case ProfileDocumentTitles.documentTitle4:
        return "Document 4";
      case ProfileDocumentTitles.documentTitle5:
        return "Document 5";
      default:
        return null;
    }
  }

  String? get key {
    switch (this) {
      case ProfileDocumentTitles.documentTitle1:
        return "document1";
      case ProfileDocumentTitles.documentTitle2:
        return "document2";
      case ProfileDocumentTitles.documentTitle3:
        return "document3";
      case ProfileDocumentTitles.documentTitle4:
        return "document4";
      case ProfileDocumentTitles.documentTitle5:
        return "document5";
      default:
        return null;
    }
  }
}
