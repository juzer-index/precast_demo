export 'UserManagement.dart';
class UserManagement {
  final int? id;
  final String? userFileDcdUserID;
  final String? password;
  final String? userFileName;
  final String? userFileAddress1;
  final String? userFileAddress2;
  final String? userFileCity;
  final String? userFileState;
  final String? userFileZIP;
  final String? userFileCountry;
  final String? userFileOfficePhone;
  final String? userFilePhone;
  final String? userFileEMailAddress;
  final bool? userFileSecurityMgr;
  final String? userFileCurComp;

  final String? rowIdent;
  final String? firstName;
  final String? lastName;
  final bool? status;
  final bool? isDefault;
  final int? tenantId;
  final String? epicorUserId;
  final bool? isEpicor;
  final bool? isActive;

  final String? resetcodesAsString;
  final bool? isEmailConfirmed;
  final String? companyId;

  final Tenant? tenant;

  const UserManagement({
    this.id,
    this.userFileDcdUserID,
    this.password,
    this.userFileName,
    this.userFileAddress1,
    this.userFileAddress2,
    this.userFileCity,
    this.userFileState,
    this.userFileZIP,
    this.userFileCountry,
    this.userFileOfficePhone,
    this.userFilePhone,
    this.userFileEMailAddress,
    this.userFileSecurityMgr,
    this.userFileCurComp,

    this.rowIdent,
    this.firstName,
    this.lastName,
    this.status,
    this.isDefault,
    this.tenantId,
    this.epicorUserId,
    this.isEpicor,
    this.isActive,

    this.resetcodesAsString,
    this.isEmailConfirmed,
    this.companyId,

    this.tenant,

  });
  static UserManagement fromJson(Map<String, dynamic> json) => UserManagement(
    id: json['id'] as int?,
    userFileDcdUserID: json['userFile_DcdUserID'] as String?,
    password: json['password'] as String?,
    userFileName: json['userFile_Name'] as String?,
    userFileAddress1: json['userFile_Address1'] as String?,
    userFileAddress2: json['userFile_Address2'] as String?,
    userFileCity: json['userFile_City'] as String?,
    userFileState: json['userFile_State'] as String?,
    userFileZIP: json['userFile_ZIP'] as String?,
    userFileCountry: json['userFile_Country'] as String?,
    userFileOfficePhone: json['userFile_OfficePhone'] as String?,
    userFilePhone: json['userFile_Phone'] as String?,
    userFileEMailAddress: json['userFile_EMailAddress'] as String?,
    userFileSecurityMgr: json['userFile_SecurityMgr'] as bool?,
    userFileCurComp: json['userFile_CurComp'] as String?,

    rowIdent: json['rowIdent'] as String?,
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    status: json['status'] as bool?,
    isDefault: json['isDefault'] as bool?,
    tenantId: json['tenantId'] as int?,
    epicorUserId: json['epicorUserId'] as String?,
    isEpicor: json['isEpicor'] as bool?,
    isActive: json['isActive'] as bool?,

    resetcodesAsString: json['resetcodesAsString'] as String?,
    isEmailConfirmed: json['isEmailConfirmed'] as bool?,
    companyId: json['companyId'] as String?,

    tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant'] as Map<String, dynamic>) : null,

  );
}

class Tenant {
  final int? id;
  final String? tenantID;
  final String? tenantName;
  final String? tenantMailId;
  final String? tenantPhoneNumber;
  final int? active;
  final bool? isDefault;
  final String? tenantIconUrl;
  final DateTime? expiredOn;
  final dynamic customerMaster;
  final List<dynamic>? tenantConfigs;
  final List<dynamic>? userManagements;
  final List<dynamic>? roles;

  const Tenant({
    this.id,
    this.tenantID,
    this.tenantName,
    this.tenantMailId,
    this.tenantPhoneNumber,
    this.active,
    this.isDefault,
    this.tenantIconUrl,
    this.expiredOn,
    this.customerMaster,
    this.tenantConfigs,
    this.userManagements,
    this.roles,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'] as int?,
    tenantID: json['tenantID'] as String?,
    tenantName: json['tenantName'] as String?,
    tenantMailId: json['tenantMailId'] as String?,
    tenantPhoneNumber: json['tenantPhoneNumber'] as String?,
    active: json['active'] as int?,
    isDefault: json['isDefault'] as bool?,
    tenantIconUrl: json['tenantIconUrl'] as String?,
    expiredOn: DateTime.tryParse(json['expiredOn'] as String),
    customerMaster: json['customerMaster'],
    tenantConfigs: json['tenantConfigs'] as List<dynamic>?,
    userManagements: json['userManagements'] as List<dynamic>?,
    roles: json['roles'] as List<dynamic>?,
  );
}