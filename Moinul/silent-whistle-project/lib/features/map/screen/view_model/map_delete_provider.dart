import 'package:flutter/foundation.dart';
import 'package:jwells/core/constant/api_endpoints.dart';
import 'package:jwells/core/services/api_services/api_services.dart';

class MapDeleteProvider extends ChangeNotifier{
    ApiService _apiService = ApiService();

  bool _isloading = false;
  String? _successMessage;
  String? _errorMessage;

  bool get isloading =>_isloading;

  String? get successMessage => _successMessage;
  String? get errorMessage =>_errorMessage;
  Future<bool> deleteMapDetails({required String id})async{
    try{
      _isloading =true;
      _successMessage=null;
      _errorMessage =null;
      notifyListeners();
      final url = ApiEndPoints.mapDelete(id);
      final  response =await _apiService.delete(url);

      final data =response.data;

      if(response.statusCode==200 || response.statusCode==201){

        _successMessage=data['message'];
        return true;
      }
      else{
        return false;
      }

    }
    catch(e){
     _isloading=false;
      return false;
    }
    finally{
      _isloading=false;
      notifyListeners();
   
    }
  }
}