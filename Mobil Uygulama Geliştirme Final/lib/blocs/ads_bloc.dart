import 'package:travel_hour/config/config.dart';

import 'package:firebase_admob/firebase_admob.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';

class AdsBloc extends ChangeNotifier {

  int _clickCounter = 0;

  int get clickCounter => _clickCounter;

  bool _adsEnabled = false;

  bool get adsEnabled => _adsEnabled;

  Future checkAdsEnable () async {

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('admin').doc('ads').get()

      .then((DocumentSnapshot snap) {

      bool _enabled = snap.data()['ads_enabled'];

      _adsEnabled = _enabled;
      
      notifyListeners();

    }).catchError((e){

      print('error : $e');

    });

  }

  void increaseClickCounter(){

    _clickCounter ++;

    print('clicks : $_clickCounter');

    notifyListeners();

  }

  void enableAds (){

    if(_adsEnabled == true){

      loadAdmobInterstitialAd();

    }

  }

  initiateAds (){

    increaseClickCounter();

    showAdmobInterstitialAd();

  }

  @override

  void dispose() {

    disposeAdmobInterstitialAd();

    super.dispose();

  }

  bool _admobInterstialAdClosed = false;

  bool get admobInterStitialAdClosed => _admobInterstialAdClosed;

  InterstitialAd _admobInterstitialAd;

  InterstitialAd get admobInterstitialAd => _admobInterstitialAd;

  initAdmob (){

    FirebaseAdMob.instance.initialize(appId: Config().admobAppId);

  }

  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(

    childDirected: false,

    nonPersonalizedAds: true,

  );

  InterstitialAd createAdmobInterstitialAd() {

    return InterstitialAd(

      adUnitId: Config().admobInterstitialAdId,

      targetingInfo: targetingInfo,

      listener: (MobileAdEvent event) {

        print("InterstitialAd event $event");

        if (event == MobileAdEvent.closed) {

          loadAdmobInterstitialAd();
          
        } else if (event == MobileAdEvent.failedToLoad) {

          disposeAdmobInterstitialAd().then((_) {

            loadAdmobInterstitialAd();

          });

        }

        notifyListeners();

      },

    );

  }

  Future loadAdmobInterstitialAd() async {

    await _admobInterstitialAd?.dispose();

    _admobInterstitialAd = createAdmobInterstitialAd()..load();

    notifyListeners();

  }

  Future disposeAdmobInterstitialAd() async {

    _admobInterstitialAd?.dispose();

    notifyListeners();

  }

  showAdmobInterstitialAd() {

    if(_clickCounter % Config().userClicksAmountsToShowEachAd == 0){

      _admobInterstitialAd?.show();

    }

    notifyListeners();

  }