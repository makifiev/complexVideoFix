//
//  AuthView.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 05.04.2021.
//


import UIKit
import Alamofire
import MRProgress

protocol AuthViewDelegate
{
    func authSuccess()
}
class AuthView: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var loginViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var mainViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoLoginTopConstraint: NSLayoutConstraint!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var authIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginButtonsView: UIView!
    @IBOutlet weak var logologin: UIImageView!
    @IBOutlet weak var authWarnLabel: UILabel!
    @IBOutlet weak var errorAuthLabel: UILabel!
    
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var authScrollView: UIScrollView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var authorizeButton: UIButton!
    
    @IBOutlet weak var pinLabelTopConstr: NSLayoutConstraint!
    
    @IBOutlet weak var mPinCodeError: UILabel!
    @IBOutlet weak var mEnterPinCode: UILabel!
    @IBOutlet weak var mCreatePinCode: UILabel!
    @IBOutlet weak var mRegError: UILabel!
    @IBOutlet weak var mEnterCurrentPinCode: UILabel!
    @IBOutlet weak var mEnterNewPinCode: UILabel!
    @IBOutlet weak var mChangePinCodeError: UILabel!
    @IBOutlet weak var pinCodeView: UIView!
    
    @IBOutlet weak var firstPinIndicator: UIView!
    @IBOutlet weak var secondPinIndicator: UIView!
    @IBOutlet weak var thirdPinIndicator: UIView!
    @IBOutlet weak var fouthPinIndicator: UIView!
    
    @IBOutlet weak var pinCodeActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var firstPinBut: UIButton!
    @IBOutlet weak var secPinBut: UIButton!
    @IBOutlet weak var thirdPinBut: UIButton!
    @IBOutlet weak var fourthPinBut: UIButton!
    @IBOutlet weak var fifthPinBut: UIButton!
    @IBOutlet weak var sixsPinBut: UIButton!
    @IBOutlet weak var sevPinBut: UIButton!
    @IBOutlet weak var eightsPinBut: UIButton!
    @IBOutlet weak var ninesPinBut: UIButton!
    @IBOutlet weak var mTouchId: UIButton!
    @IBOutlet weak var zeroPinBut: UIButton!
    @IBOutlet weak var backPinBut: UIButton!
    
    @IBOutlet weak var pinButtonView: UIView!
    @IBOutlet weak var supportButtonsView: UIView!
     var mChangePinCode = UIButton()
     var mChangeUser = UIButton()
    @IBOutlet weak var supportViewBottomConstr: NSLayoutConstraint!
    @IBOutlet weak var pinCodeCircles: UIView!
    
    let pinCodeViewIpad = UIView()
    
    var passwordItem: KeychainPasswordItem!
    let touchMe = BiometricIDAuth()
    var array: NSDictionary = [:]
    var disableTouch = true
    var mLoadingProgress = MRCircularProgressView()
    let loading = UILabel()
    var mTouchIdIpad = UIButton()
    static var keyBoardHeightDiffer:CGFloat!
    
    var diff:CGFloat = 0
    var pinButtonsArray:[UIButton]!
    var pinButtonsNum:[String] = ["1","2","3","4","5","6","7","8","9","0"]
    var pinIndicatorArray:[UIView]!
    var modelHeightChanges = 0
    var pinCode:String = ""
    var savedPin:String! = ""
    var changePassword:String = ""
    var originCenterChangeUser:CGFloat!
    var errorPinsCount:Int = 0
    var loginButtonsViewPos: CGFloat!
    let userDevice = UIDevice.current.identifierForVendor?.uuidString.split(separator: "-")
    var mDelegate : AuthViewDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        self.mainView.layer.insertSublayer(setGradientBackground(colorTop: .blueBackground, colorBottom: .darkBlueBackground), at:0)
        self.hideKeyboardWhenTappedAround()
        self.pinCodeView.layer.insertSublayer(setGradientBackground(colorTop: .blueBackground, colorBottom: .darkBlueBackground), at:0)
        
        diffcount()
        setSceneView()
        originCenterChangeUser = mChangeUser.center.x
        errorPinsCount = 0
        addLoadingView()
        UserDefaults.standard.set(false, forKey: "change")
        UserDefaults.standard.synchronize()
        
        let defaults = UserDefaults.standard
        defaults.setValue(0, forKey: Constant.showTabBarButtons)
        defaults.synchronize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        AuthView.keyBoardHeightDiffer = self.view.frame.height - userPasswordTextField.frame.origin.y - userPasswordTextField.frame.height - 15
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if  UserDefaults.standard.bool(forKey: "logout") == true
        {
            self.blackOut()
            self.mLoadingProgress.removeFromSuperview()
            self.loading.removeFromSuperview()
            addLoadingView()
//            self.mLoadingProgress.alpha = 0
//            self.loading.alpha = 0
            self.pinCodeView.alpha = 0
//            replaceViews(side: false)
            self.loginButtonsView.alpha = 1
            self.loginButtonsView.isHidden = false
            UserDefaults.standard.set(false, forKey: "logout")
            UserDefaults.standard.synchronize()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLogoConstr()
        if UserDefaults.standard.bool(forKey: "saved") == true
        {
            showPinView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.touchIDLoginAction()
            }
        }
        else
        {
            showLoginView()
        }
        loginButtonsViewPos = self.loginButtonsView.frame.origin.y
        
    }
    
   func showPinView()
    {
        showLoadView(alpha: 0)
        mChangePinCode.alpha = 1
        mChangeUser.center.x = originCenterChangeUser
        replaceViews(side: true)
    }
    func showLoginView()
    {
        showLoadView(alpha: 0)
        replaceViews(side: false)
        mChangePinCode.alpha = 0
        mChangeUser.center.x = self.view.frame.width/2
    }
    
    func addLoadingView()
    {
        
        loading.labelWithFrame(frame: CGRect.zero, colors: [UIColor.White, UIColor.clear])
        loading.text = "Загрузка"
        loading.font = Constant.setMediumFont(size: 14)
        loading.sizeToFit()
        loading.center.x = self.view.center.x
        loading.frame.origin.y = self.view.frame.height - 60
        loading.alpha = 0
        self.view.addSubview(loading)
        
        mLoadingProgress.frame.size = CGSize(width: 20, height: 20)
        mLoadingProgress.center.x = self.view.center.x
        mLoadingProgress.frame.origin.y = loading.frame.origin.y - mLoadingProgress.frame.height - 10
        mLoadingProgress.borderWidth = 0
        mLoadingProgress.lineWidth = 2
        mLoadingProgress.tintColor = UIColor.White
        mLoadingProgress.setProgress(0.0, animated: false)
        mLoadingProgress.valueLabel.isHidden = true
        self.view.addSubview(mLoadingProgress)
        
        let rotationAnumation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnumation.toValue = Double.pi * 2
        rotationAnumation.duration = 1
        rotationAnumation.isCumulative = true
        rotationAnumation.repeatCount = 1000
        mLoadingProgress.layer.add(rotationAnumation, forKey: "rotationAnimation")
        
    }
    override func keyboardWillShow(notification: NSNotification) {
        if userNameTextField.text?.isEmpty == false && userPasswordTextField.text?.isEmpty == false
        {
            if authIndicator.isAnimating == false
            {
                self.authorizeButton.alpha = 1
                errorAuthLabel.alpha = 0
            }
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            
            
            let loginEndYPos = userPasswordTextField.frame.origin.y + userPasswordTextField.frame.height
            let keyStartYPos = self.view.frame.size.height - keyboardSize.size.height
            print(loginButtonsViewPos)
            print(self.loginButtonsView.frame.origin.y)
            if self.loginButtonsView.frame.origin.y == loginButtonsViewPos
            {
                if loginEndYPos > keyStartYPos
                {
                    self.loginButtonsView.frame.origin.y -= loginEndYPos - keyStartYPos + 15
                    self.loginButtonsView.layoutIfNeeded()
                }
            }
        }
    }
    override func keyboardWillHide(notification: NSNotification)
    {
        self.loginButtonsView.frame.origin.y = loginButtonsViewPos
        self.loginButtonsView.layoutIfNeeded()
    }
    
   
    func setSceneView()
    {
        setConstraints()
        setAuthView()
        setPincodeView()
        cycleForRound()
    }
    
    func setConstraints()
    {
        
        setPinLabelConstr()
        setSupportPinView()
    }
    
    func setLogoConstr()
    {
        for constraint in self.view.constraints {
            if constraint.identifier == "logoLoginTopConstraint" {
                constraint.constant = self.view.frame.height/4 - 15
            }
        }
        mainView.layoutIfNeeded()
    }
    
    func setPinLabelConstr()
    {
        switch UIDevice().type
        {
        case .iPhone4: modelHeightChanges = -50
        case .iPhoneX: modelHeightChanges = 10
        default:  modelHeightChanges = 0
            break
        }
        
        pinLabelTopConstr.constant = self.view.frame.height/3 + CGFloat(modelHeightChanges)
        
        pinCodeView.layoutIfNeeded()
    }
    
    func setSupportPinView()
    {
        if UIScreen.main.bounds.height > 800
        {
            supportViewBottomConstr.constant = 24
        }
        else
        {
            supportViewBottomConstr.constant = 0
        }
    }
    
    func setAuthView()
    {
        self.view.bringSubviewToFront(logologin)
        authScrollView.showsHorizontalScrollIndicator = false
        authScrollView.isPagingEnabled = true
        authScrollView.isScrollEnabled = false
        
        pinCodeActivityIndicator.alpha = 0
        
        authWarnLabel.text = "Введите логин и пароль"
        authWarnLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        authWarnLabel.sizeToFit()
        
        userNameTextField.textAlignment = .center
        userNameTextField.delegate = self
        userNameTextField.layer.borderWidth = 0.6
        userNameTextField.layer.borderColor = UIColor.white.cgColor
        userNameTextField.textColor = .white
        userNameTextField.backgroundColor = .clear
        userNameTextField.layer.cornerRadius = userNameTextField.frame.height/2
        userNameTextField.keyboardType = UIKeyboardType.emailAddress
        if #available(iOS 12.0, *) {
            userNameTextField.textContentType = UITextContentType.oneTimeCode
        } else {
            // Fallback on earlier versions
        }
        userNameTextField.placeholder = "Логин"
        userNameTextField.font = UIFont(name: "HelveticaNeue", size: 18)
        userNameTextField.addTarget(self, action: #selector(AuthView.textFieldDidChange(_:)), for: .editingChanged)
        
        userPasswordTextField.textAlignment = .center
        userPasswordTextField.delegate = self
        userPasswordTextField.returnKeyType = .done
        userPasswordTextField.layer.borderWidth = 0.6
        userPasswordTextField.layer.borderColor = UIColor.white.cgColor
        userPasswordTextField.backgroundColor = .clear
        userPasswordTextField.keyboardType = UIKeyboardType.emailAddress
        if #available(iOS 12.0, *) {
            userPasswordTextField.textContentType = UITextContentType.oneTimeCode
        } else {
            // Fallback on earlier versions
        }
        userPasswordTextField.textColor = .white
        userPasswordTextField.layer.cornerRadius = userNameTextField.frame.height/2
        userPasswordTextField.placeholder = "Пароль"
        userPasswordTextField.font = UIFont(name: "HelveticaNeue", size: 18)
        userPasswordTextField.addTarget(self, action: #selector(AuthView.textFieldDidChange(_:)), for: .editingChanged)
        
        
        userNameTextField.delegate = self as UITextFieldDelegate
        userNameTextField.returnKeyType = .next
        
        userPasswordTextField.delegate = self as UITextFieldDelegate
        userPasswordTextField.returnKeyType = .done
        
        placeHolderColor(textField: userNameTextField, text: "Логин")
        placeHolderColor(textField: userPasswordTextField, text: "Пароль")
        
        
        authorizeButton.alpha = 0.5
        authorizeButton.isEnabled = false
        authorizeButton.layer.cornerRadius = authorizeButton.frame.height/2
        authorizeButton.layer.masksToBounds = true
        authorizeButton.setTitle("Войти", for: .normal)
        authorizeButton.titleLabel?.font =  UIFont(name: "HelveticaNeue-Medium", size: 18)
        
        authorizeButton.layer.insertSublayer(setGradientBackground(colorTop: .lightOrangeAuth, colorBottom: .orangeAuth), at:0)
        authorizeButton.setTitleColor(UIColor.white, for: .normal)
        authorizeButton.addTarget(self, action: #selector(pressLoginButton), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            pinCodeActivityIndicator.style = UIActivityIndicatorView.Style.medium
        } else {
            pinCodeActivityIndicator.style = .white
        }
    }
    
  
    func setPincodeView()
    {
        pinIndicatorArray = [firstPinIndicator,secondPinIndicator,thirdPinIndicator,fouthPinIndicator]
        
        for i in stride(from: 0, to: pinIndicatorArray.count, by: 1)
        {
            var view = pinIndicatorArray[i]
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 0.6
        }
    }
    
    func placeHolderColor(textField: UITextField, text: String)
    {
        let color = UIColor.white
        let placeholder = textField.placeholder ?? text
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : color])
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) -> CAGradientLayer
    {
        let colorTops = colorTop
        let colorBottoms = colorBottom
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTops.cgColor, colorBottoms.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width,  height: self.view.frame.height)
        
        
        return gradientLayer
    }
    // MARK: - setup pin buttons
    func roundedButtons(button: UIButton) -> UIButton
    {
        button.layer.cornerRadius = button.frame.width / 2
        return button
    }
    
    func addPinCodeView()
    {
        pinButtonsArray =
            [
                firstPinBut,
                secPinBut,
                thirdPinBut,
                fourthPinBut,
                fifthPinBut,
                sixsPinBut,
                sevPinBut,
                eightsPinBut,
                ninesPinBut,
                zeroPinBut
            ]
        
        for i in stride(from: 0, to: pinButtonsArray.count, by: 1)
        {
            pinButtonsArray[i].isHidden = true
        }
        pinCodeViewIpad.frame.size = pinButtonView.frame.size
//        pinCodeViewIpad.frame.origin.x = pinButtonView.frame.width
        pinCodeViewIpad.backgroundColor = .clear
        pinButtonView.addSubview(pinCodeViewIpad)
        pinButtonView.backgroundColor = .clear
//        pinButtonView.alpha = 0
        
        let board = UIView()
        pinCodeViewIpad.addSubview(board)
        let symbols = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        for i in 0..<symbols.count
        {
            let size:Double = Constant.iphone6 ? 70 : 55
            let xOffSet:Double = Constant.iPhone6Plus ? 38 : 30
            let yOffSet:Double = Constant.iPhone6Plus ? 20 : 12
            
            let first = size + xOffSet
            let x = Float(first) * (Float(i) - 3 * floorf(Float(i) / 3))
            let y = Float(first) * floorf(Float(i) / 3)
            
            let button = UIButton()
            button.setButtonWithTitle(title: symbols[i], font: Constant.setMediumFont(size: 32), colors: [UIColor.White, UIColor.AuthLightBlue, UIColor.clear])
            button.frame = CGRect(x: Double(x), y: Double(y), width: size, height: size)
            button.layer.borderColor = UIColor.White.cgColor
            button.layer.borderWidth = 0.6
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
            button.setBackgroundColor(.clear, for: .normal)
            button.setBackgroundColor(.White, for: .highlighted)
            button.addTarget(self, action: #selector(pinButtonPress), for: .touchUpInside)
            button.addTarget(self, action: #selector(addPinNumber), for: .touchUpInside)
            board.addSubview(button)
            
            if symbols[i] == "0"
            {
                button.frame.origin.x += CGFloat(size + xOffSet)

                    mTouchId.frame.size = CGSize(width: size, height: size)
                    mTouchId.frame.origin = CGPoint(x: Double(button.frame.origin.x) - size - xOffSet, y: Double(y))
                    mTouchId.layer.cornerRadius = button.frame.height / 2
                    mTouchId.layer.masksToBounds = true
                    mTouchId.setBackgroundColor(.clear, for: .normal)
                    mTouchId.setBackgroundColor(UIColor.White.withAlphaComponent(0.3), for: .highlighted)
                    mTouchId.tag = 10
                    mTouchId.addTarget(self, action: #selector(pinButtonPress), for: .touchUpInside)
                    board.addSubview(mTouchId)
                    switch touchMe.biometricType()
                    {
                    case .faceID:
                        self.changePinButtonTint(button: mTouchId,
                                                 image: "faceid-icon",
                                                 tintColor: UIColor.white)
                    case .touchID:
                        self.changePinButtonTint(button: mTouchId,
                                                 image: "icon-fingerprint",
                                                 tintColor: UIColor.white)
                    case .none:
                        mTouchId.isHidden = true
                    }
            
                
                if UserDefaults.standard.bool(forKey: "saved") != true
                {
                    self.mTouchId.alpha = 0
                }
                else
                {
                    self.mTouchId.alpha = 1
                }
                
                let backSpace = UIButton()
                backSpace.setButtonWithImage(image: "pincode-backspace", highlightedImage: "pincode-backspace")
                backSpace.frame.size = CGSize(width: size, height: size)
                backSpace.frame.origin = CGPoint(x: Double(button.frame.origin.x) + size + xOffSet, y: Double(y))
                backSpace.layer.cornerRadius = button.frame.height / 2
                backSpace.layer.masksToBounds = true
                backSpace.setBackgroundColor(.clear, for: .normal)
                backSpace.setBackgroundColor(UIColor.White.withAlphaComponent(0.3), for: .highlighted)
                backSpace.addTarget(self, action: #selector(pinButtonPress), for: .touchUpInside)
                backSpace.addTarget(self, action: #selector(deletePinNumber), for: .touchUpInside)
                backSpace.tag = 12
                board.addSubview(backSpace)
                board.backgroundColor = .clear
                board.frame.size = CGSize(width: backSpace.frame.origin.x + backSpace.frame.width, height: backSpace.frame.origin.y + backSpace.frame.height)
                board.center.x = self.pinCodeViewIpad.frame.width / 2
                board.frame.origin.y = self.pinCodeViewIpad.frame.origin.y
            }
        }
        
        mChangePinCode.setButtonWithTitle(title: "Изменить ПИН-код", font: Constant.setMediumFont(size: 15), colors: [UIColor.White, UIColor.White.withAlphaComponent(0.3), UIColor.clear])
        mChangePinCode.frame.origin = CGPoint(x: 40, y: self.view.frame.height - mChangePinCode.frame.height - 5 - (Constant.iPhoneX ? 24 : 0))
  
        self.pinCodeView.addSubview(mChangePinCode)
 
        mChangeUser.setButtonWithTitle(title: "Другой пользователь", font: Constant.setMediumFont(size: 15), colors: [UIColor.White, UIColor.White.withAlphaComponent(0.3), UIColor.clear])
        mChangeUser.frame.origin = CGPoint(x: self.view.frame.width - mChangeUser.frame.width - 40, y: mChangePinCode.frame.origin.y)
 
        self.pinCodeView.addSubview(mChangeUser)
        
        mChangePinCode.addTarget(self, action: #selector(changePinAction), for: .touchUpInside)
        mChangeUser.addTarget(self, action: #selector(changeUserActionsender), for: .touchUpInside)
    }
    
    func cycleForRound()
    {
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.addPinCodeView()
        }
        else
        {
            pinButtonsArray =
                [
                    firstPinBut,
                    secPinBut,
                    thirdPinBut,
                    fourthPinBut,
                    fifthPinBut,
                    sixsPinBut,
                    sevPinBut,
                    eightsPinBut,
                    ninesPinBut,
                    zeroPinBut
                ]
            
            for i in stride(from: 0, to: pinButtonsArray.count, by: 1)
            {
                var button = pinButtonsArray[i]
                button.setTitle(pinButtonsNum[i], for: .normal)
                button = roundedButtons(button: button)
                
                button.layoutIfNeeded()
                button.addTarget(self, action: #selector(pinButtonPress), for: [.touchDown,.touchDragEnter])
                button.addTarget(self, action: #selector(pinButtonDrop), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
                button.addTarget(self, action: #selector(addPinNumber), for: .touchUpInside)
                button.layer.borderWidth = 0.6
                button.layer.borderColor = UIColor.white.cgColor
                button.titleLabel?.font = .systemFont(ofSize: 32, weight: .medium)
                button.setTitleColor(.white, for: .normal)
                button.setBackgroundColor(.clear, for: .normal)
                
                button.setTitleColor(UIColor.blueBackground, for: .highlighted)
                button.setBackgroundColor(.white, for: .highlighted)
            }
            
            
            switchBiometricType()
            
            if UserDefaults.standard.bool(forKey: "saved") != true
            {
                self.mTouchId.alpha = 0
            }
            else
            {
                self.mTouchId.alpha = 1
            }
            
            mTouchId.setBackgroundColor(.clear, for: .normal)
            mTouchId.setBackgroundColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5), for: .highlighted)
            
            mTouchId.tag = 10
            mTouchId.addTarget(self, action: #selector(pinButtonPress), for: [.touchDown,.touchDragEnter])
            mTouchId.addTarget(self, action: #selector(pinButtonDrop), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
            mTouchId.addTarget(self, action: #selector(touchIDLoginAction), for: [.touchUpInside])
            
            backPinBut.setImage(UIImage(named: "pincode-backspace"), for: .normal)
            backPinBut.setBackgroundColor(.clear, for: .normal)
            backPinBut.setBackgroundColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5), for: .highlighted)
            self.changePinButtonTint(button: backPinBut,
                                     image: "pincode-backspace",
                                     tintColor: UIColor.white)
            backPinBut.tag = 12
            
            pinButtonView.backgroundColor = .clear
            
            backPinBut.addTarget(self, action: #selector(pinButtonPress), for: [.touchDown,.touchDragEnter])
            backPinBut.addTarget(self, action: #selector(pinButtonDrop), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
            backPinBut.addTarget(self, action: #selector(deletePinNumber), for: .touchUpInside)
            
            mChangePinCode.setButtonWithTitle(title: "Изменить ПИН-код", font: Constant.setMediumFont(size: 12), colors: [UIColor.White, UIColor.White.withAlphaComponent(0.3), UIColor.clear])
            mChangePinCode.frame.origin = CGPoint(x: 40, y: self.view.frame.height - mChangePinCode.frame.height - 5 - (Constant.iPhoneX ? 24 : 0))
//            mChangePinCode.addTarget(self, action: #selector(changePinAction), for: .touchUpInside)
            self.pinCodeView.addSubview(mChangePinCode)
            
    //        mChangeUser = UIButton()
            mChangeUser.setButtonWithTitle(title: "Другой пользователь", font: Constant.setMediumFont(size: 12), colors: [UIColor.White, UIColor.White.withAlphaComponent(0.3), UIColor.clear])
            mChangeUser.frame.origin = CGPoint(x: self.view.frame.width - mChangeUser.frame.width - 40, y: mChangePinCode.frame.origin.y)
//            mChangeUser.addTarget(self, action: #selector(changeUserActionsender), for: .touchUpInside)
            self.pinCodeView.addSubview(mChangeUser)
            
            mChangePinCode.addTarget(self, action: #selector(changePinAction), for: .touchUpInside)
            mChangeUser.addTarget(self, action: #selector(changeUserActionsender), for: .touchUpInside)
            
        }
    }
    
    func resetPinIndicator()
    {
        self.pinCode = ""
        self.updatePinCodeIndicator()
    }
    
    func confirmPin(checkNum: String)
    {
        if UserDefaults.standard.bool(forKey: "saved") != true || UserDefaults.standard.bool(forKey: "rewritePin") == true
        {
            let alertController = UIAlertController(title: "Сохранить ПИН-код?",
                                                    message: "Введенный ПИН-код: \(String(self.pinCode))",
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:
                                                        {_ in
                                                            CATransaction.setCompletionBlock({
                                                                self.resetPinIndicator()
                                                                
                                                                
                                                            })
                                                        }))
            alertController.addAction(UIAlertAction(title: "Да", style: .default, handler:
                                                        {_ in
                                                            
                                                            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                                                                self.pinCodeView.frame.origin.x = -self.view.frame.width
                                                            }, completion: { _ in
                                                                var savedPassword = ""
                                                                var savedLogin = ""
                                                                do {
                                                                    self.passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                                                                             account: "KKVF",
                                                                                                             accessGroup: KeychainConfiguration.accessGroup)
                                                                    
                                                                    savedPassword = try  self.passwordItem.readData().object(forKey: "password") as! String
                                                                    savedLogin = try  self.passwordItem.readData().object(forKey: "username") as! String
                                                                }
                                                                catch {
                                                                    fatalError("Error updating keychain - \(error)")
                                                                }
                                                                self.authRequest(username: savedLogin, password: savedPassword)
                                                            })
                                                            self.saveExistKeyChein()
                                                            self.pinCode = ""
                                                            for i in stride(from: 0, to: self.pinIndicatorArray.count, by: 1)
                                                            {
                                                                let circle = self.pinIndicatorArray[i]
                                                                circle.backgroundColor = (i < self.pinCode.count) ? .white : .clear
                                                            }
                                                            
                                                            UserDefaults.standard.setValue(true, forKey: "saved")
                                                            UserDefaults.standard.setValue(false, forKey: "rewritePin")
                                                            UserDefaults.standard.synchronize()
                                                        }))
            self.present(alertController, animated: true)
        }
        else
        {
            CATransaction.setCompletionBlock({
                self.resetPinIndicator()
            })
            self.checkSavedPin(сheckNum: checkNum)
        }
    }
    
    func threeErrorPins()
    {
        if errorPinsCount == 3
        {
            
            
            let alertController = UIAlertController(title: "Ошибка",
                                                    message: "Вы ввели неверный ПИН-код 3 раза подряд!",
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler:
                                                        {_ in
                                                            UIView.animate(withDuration: 0.3,
                                                                           animations: {
                                                                            self.replaceViews(side: false)
                                                                            self.blackOut()
                                                                           })
                                                        }))
            self.present(alertController, animated: true)
            errorPinsCount = 0
        }
    }
    
    @objc func changePinAction(sender: UIButton!)
    {
        let alert = UIAlertController(title: "Вы уверены, что хотите изменить ПИН-код?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler:
                                        {
                                            action in
                                            switch action.style
                                            {
                                            case .cancel:
                                                print("cancel")
                                            case .default:
                                                print("def")
                                                self.resetPinIndicator()
                                                self.changeLabelsAlpha(label: self.mEnterCurrentPinCode)
                                                UserDefaults.standard.set(true, forKey: "change")
                                                
                                                UserDefaults.standard.synchronize()
                                                
                                                UIView.animate(withDuration: 0.2,
                                                               animations: {
                                                                self.mChangePinCode.alpha = 0
                                                                self.mTouchId.alpha = 0
                                                                self.mChangeUser.center.x = self.view.frame.width/2
                                                               })
                                                
                                            case .destructive:
                                                print("destr")
                                                
                                            }
                                        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @objc func changeUserActionsender(sender: UIButton!)
    {
        let alert = UIAlertController(title: "Вы уверены, что хотите сменить текущего пользователя?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            switch action.style{
            case .default:
                self.changeUser()
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func changeUser()
    {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.replaceViews(side: false)
                        self.blackOut()
                        
                       })
    }
    @objc func pinButtonPress(sender: UIButton!)
    {
        let btnsendtag: UIButton = sender
        
        UIView.transition(with: btnsendtag,
                          duration: 0.3,
                          options: [.transitionCrossDissolve,.allowUserInteraction],
                          animations: {
                            if btnsendtag.tag == 10
                            {
                                self.switchBiometricType()
                                
                            }
                            else  if btnsendtag.tag == 12
                            {
                                self.changePinButtonTint(button: btnsendtag,
                                                         image: "pincode-backspace",
                                                         tintColor:UIColor.white)
                            }
                          },
                          completion: nil)
        
    }
    
    @objc func pinButtonDrop(sender: UIButton!)
    {
        let btnsendtag: UIButton = sender
        UIView.transition(with: btnsendtag,
                          duration: 0.3,
                          options: [.transitionCrossDissolve,.allowUserInteraction],
                          animations: {
                            if btnsendtag.tag == 10
                            {
                                self.switchBiometricType()
                            }
                            else  if btnsendtag.tag == 12
                            {
                                self.changePinButtonTint(button: btnsendtag,
                                                         image: "pincode-backspace",
                                                         tintColor: UIColor.white)
                            }
                          },
                          completion: nil)
        
    }
    
    @objc func addPinNumber(sender: UIButton!)
    {
        
        let btnsendtag: UIButton = sender
        let title:String! = sender.titleLabel!.text
        if pinCode.count < 4
        {
            pinCode.append(title)
        }
        if pinCode.count == 4
        {
            if UserDefaults.standard.bool(forKey: "change") == true
            {
                print("change")
                
                var сheckNum = pinCode
                self.checkSavedPin(сheckNum: сheckNum)
            }
            else
            {
                print (pinCode)
                savedPin = pinCode
                var сheckNum = pinCode
                confirmPin(checkNum: сheckNum)
            }
        }
        self.updatePinCodeIndicator()
        Vibration.light.vibrate()
    }
    
    @objc func deletePinNumber(sender: UIButton!)
    {
        
        if pinCode.count != 0
        {
            pinCode.remove(at: pinCode.index(before: pinCode.endIndex))
            
        }
        else
        {
            print("No value")
        }
        
        self.updatePinCodeIndicator()
        Vibration.light.vibrate()
    }
    
    @objc func pressLoginButton(sender: UIButton!)
    {
       
        self.authRequest(username: self.userNameTextField.text ?? "", password: self.userPasswordTextField.text ?? "")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if userNameTextField.text?.isEmpty == false && userPasswordTextField.text?.isEmpty == false
        {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.authorizeButton.alpha = 1
                            self.authorizeButton.isEnabled = true
                            self.errorAuthLabel.alpha = 0
                           })
        }
        else
        {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.authorizeButton.alpha = 0.5
                            self.authorizeButton.isEnabled = false
                            self.errorAuthLabel.alpha = 0
                           })
        }
        
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        if textField == userNameTextField
        {
            userPasswordTextField.becomeFirstResponder()
            textField.returnKeyType = .next
        }
        
        else if textField == userPasswordTextField
        {
            textField.resignFirstResponder()
            textField.returnKeyType = .done
            if userNameTextField.text?.isEmpty == false && userPasswordTextField.text?.isEmpty == false
            {
                
                self.authRequest(username: self.userNameTextField.text ?? "", password: self.userPasswordTextField.text ?? "")
                
            }
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func changePinButtonTint(button: UIButton, image:String, tintColor:UIColor)
    {
        let image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.tintColor = tintColor
    }
    
    func updatePinCodeIndicator()
    {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        for i in stride(from: 0, to: self.pinIndicatorArray.count, by: 1)
                        {
                            let circle = self.pinIndicatorArray[i]
                            circle.backgroundColor = (i < self.pinCode.count) ? .white : .clear
                        }
                       })
    }
    
    func replaceViews(side:Bool)
    {
        if side
        {
            self.loginButtonsView.frame.origin.x = -self.view.frame.width
            self.pinCodeView.frame.origin.x = 0
            for constraint in self.view.constraints {
                if constraint.identifier == "logoLoginTopConstraint" {
                    constraint.constant = self.view.frame.height/4 - self.diff
                }
            }
            mainView.layoutIfNeeded()
        }
        else
        {
            self.loginButtonsView.frame.origin.x = 0
            self.pinCodeView.frame.origin.x = self.view.frame.width
            for constraint in self.view.constraints {
                if constraint.identifier == "logoLoginTopConstraint" {
                    constraint.constant = self.view.frame.height/4 - 15
                }
            }
            mainView.layoutIfNeeded()
            self.authWarnLabel.text = "Введите логин и пароль"
        }
    }
    
    func diffcount()
    {
        if self.view.frame.height < 490
        {
            diff = 90
        }
        else
        {
            if self.view.frame.width > 320
            {
                if self.view.frame.width > 375
                {
                    diff =   85
                }
                else
                {
                    diff =  75
                }
            }
            else
            {
                diff =  65
                
            }
        }
    }
    
    func saveExistKeyChein()
    {
        do {
            self.passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                     account: "KKVF",
                                                     accessGroup: KeychainConfiguration.accessGroup)
            if UserDefaults.standard.bool(forKey: "rewritePin") != true
            {
                self.array  = ["username":userNameTextField.text!,"password":userPasswordTextField.text!,"pincode":savedPin!]
            }
            else
            {
                let savedPassword = try  self.passwordItem.readData().object(forKey: "password") as! String
                let savedLogin = try  self.passwordItem.readData().object(forKey: "username") as! String
                self.array  = ["username":savedLogin,"password":savedPassword,"pincode":savedPin!]
            }
            
            try passwordItem.saveData(array)
            print(self.array)
            print("Succesfull save keyChain")
        }
        catch
        {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    func checkSavedPin(сheckNum: String)
    {
        do {
            self.passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                     account: "KKVF",
                                                     accessGroup: KeychainConfiguration.accessGroup)
            let savedDictionary = try  self.passwordItem.readData().object(forKey: "pincode") as! String
            let savedPassword = try  self.passwordItem.readData().object(forKey: "password") as! String
            let savedLogin = try  self.passwordItem.readData().object(forKey: "username") as! String
            
            if savedDictionary.elementsEqual(сheckNum)
            {
                if UserDefaults.standard.bool(forKey: "change") == true
                {
                    UserDefaults.standard.set(false, forKey: "change")
                    UserDefaults.standard.set(true, forKey: "rewritePin")
                    UserDefaults.standard.synchronize()
                    
                    CATransaction.setCompletionBlock({
                        self.changeLabelsAlpha(label: self.mEnterNewPinCode)
                        self.resetPinIndicator()
                        
                    })
                }
                else
                {
                    if Networking.sharedInstance.sessionToken == ""
                    {
                    self.view.isUserInteractionEnabled = false
                    self.authRequest(username: savedLogin, password: savedPassword)
                    }
                    else
                    {
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                            self.pinCodeView.frame.origin.x = -self.view.frame.width
                        }, completion: { [self] _ in
                            
                            loginButtonsView.alpha = 0
                            loadData()
                        })
                    }
                }
            }
            else
            {
                CATransaction.setCompletionBlock({
                    if UserDefaults.standard.bool(forKey: "saved") != true
                    {
                        self.changeLabelsAlpha(label: self.mChangePinCodeError)
                    }
                    else
                    {
                        self.changeLabelsAlpha(label: self.mPinCodeError)
                    }
                    
                    let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
                    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                    animation.duration = 0.6
                    animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
                    self.pinCodeCircles.layer.add(animation, forKey: "shake")
                    Vibration.error.vibrate()
                    self.errorPinsCount += 1
                    print(self.errorPinsCount)
                    self.threeErrorPins()
                    self.resetPinIndicator()
                })
            }
        }
        catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    //MARK:FACE/Touch Sys Alert
    @objc func touchIDLoginAction()
    {
        Vibration.light.vibrate()
        touchMe.authenticateUser()
        { [weak self] message in
            if let message = message
            {
                if message.contains("not available")
                {
                    let alertController = UIAlertController(title: "Внимание!",
                                                            message: "Возможность входа через \(self?.touchMe.biometricType() == .faceID ? "FaceID" : "TouchID") заблокирована",
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
                    alertController.addAction(UIAlertAction(title: "Настройки", style: .default){ _ in
                        if let url = URL(string: UIApplication.openSettingsURLString)
                        {
                            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                            })
                        }
                    })
                    self?.present(alertController, animated: true)
                }
            }
            else
            {
                do {
                    let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                            account: "KKVF",
                                                            accessGroup: KeychainConfiguration.accessGroup)
                    let savedPassword = try passwordItem.readData().object(forKey: "password") as! String
                    let savedLogin = try passwordItem.readData().object(forKey: "username") as! String
                    print(savedPassword)
                    print(savedLogin)
                    self?.authRequest(username: savedLogin, password: savedPassword)
                }
                catch {
                    fatalError("Error updating keychain - \(error)")
                }
            }
        }
    }
    
    func changeLabelsAlpha(label: UILabel)
    {
        let LabelArray = [
            mPinCodeError,
            mEnterPinCode,
            mCreatePinCode,
            mRegError,
            mEnterCurrentPinCode,
            mEnterNewPinCode,
            mChangePinCodeError
        ]
        for i in stride(from: 0, to: LabelArray.count, by: 1)
        {
            let currentLabel = LabelArray[i]
            if currentLabel == label
            {
                UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
                    currentLabel?.alpha = 1
                })
            }
            else
            {
                UIView.animate(withDuration: 0.2,
                               animations: {
                                currentLabel?.alpha = 0
                               })
            }
        }
    }
    func changeLabelText(text:String, label: UILabel)
    {
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            label.alpha = 0
        }) { (completion) in
            label.text = text
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                label.alpha = 1
            })
        }
    }
    
    func blackOut()
    {
        self.resetPinIndicator()
        self.clearTextFields(textField: userPasswordTextField, text: "", placeHolder: "Пароль")
        self.clearTextFields(textField: userNameTextField, text: "", placeHolder: "Логин")
        self.changeLabelsAlpha(label: self.mEnterPinCode)
        Networking.sharedInstance.sessionToken = ""
        mChangePinCode.alpha = 0
        mChangeUser.center.x = self.view.frame.width/2
        authorizeButton.alpha = 0.5
        authorizeButton.isEnabled = false
        UserDefaults.standard.set(false, forKey: "saved")
        UserDefaults.standard.set(false, forKey: "change")
        UserDefaults.standard.set(false, forKey: "rewritePin")
        UserDefaults.standard.set(true, forKey: Constant.registered)
        UserDefaults.standard.set(false, forKey: Constant.dataBaseCreated)
        UserDefaults.standard.set(true, forKey: "afterBlackOut")
 
        UserDefaults.standard.synchronize()
        
        switchBiometricType()
        
        let secItemClasses = [kSecClassGenericPassword,
                              kSecClassInternetPassword,
                              kSecClassCertificate,
                              kSecClassKey,
                              kSecClassIdentity]
        for secItemClass in secItemClasses {
            let dictionary = [kSecClass as String:secItemClass]
            SecItemDelete(dictionary as CFDictionary)
        }
    }
    
    func clearTextFields(textField: UITextField, text:String, placeHolder: String)
    {
        textField.text = text
        textField.placeholder = placeHolder
    }
    func switchBiometricType()
    {
        if UserDefaults.standard.bool(forKey: "saved") == true
        {
            switch touchMe.biometricType()
            {
            case .faceID:
                self.changePinButtonTint(button: mTouchId,
                                         image: "faceid-icon",
                                         tintColor: UIColor.white)
            case .touchID:
                self.changePinButtonTint(button: mTouchId,
                                         image: "icon-fingerprint",
                                         tintColor: UIColor.white)
            case .none:
                mTouchId.isHidden = true
            }
        }
        else
        {
            mTouchId.isHidden = true
        }
    }
    
    
    func loadData()
    {
        let defaults = UserDefaults.standard
        defaults.setValue(true, forKey: Constant.registered)
        defaults.synchronize()
        print(defaults.bool(forKey: Constant.dataBaseCreated))
        if defaults.bool(forKey: Constant.dataBaseCreated) == false
        {
            showLoadView(alpha: 1)
            Networking.sharedInstance.loadComplexesWithProgress(progress: mLoadingProgress)
            {
                self.loadingSuccess()
            } failure:
            {
                self.showLoadingFailureAlert()
            }
            
        }
        else
        {
            loadingSuccess()
        }
    }
    func showLoadingFailureAlert()
    {
        let alertController = UIAlertController(title: "Ошибка!",
                                                message: "Ошибка загрузки данных!",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Назад", style: .cancel)
        { _ in
            if UserDefaults.standard.bool(forKey: "saved") == true
            {
                CoreDataStack.sharedInstance.clearData() 
                self.showPinView()
            }
            else
            {
                self.showLoginView()
            }
            
        })
        alertController.addAction(UIAlertAction(title: "Повторить", style: .default)
        { _ in
            self.loadData()
        })
        self.present(alertController, animated: true)
    }
    
    func loadingSuccess()
    {
        let defaults = UserDefaults.standard
        defaults.setValue(1, forKey: Constant.showTabBarButtons)
        defaults.synchronize()
        mDelegate?.authSuccess()
        self.segueToTabBar()
    }
    
    func showLoadView(alpha: CGFloat)
    {
        loading.alpha = alpha
        mLoadingProgress.alpha = alpha
    }
    
    func authRequest(username: String, password: String)
    {
        self.pinCodeView.alpha = 1
        let strIPAddress : String = self.getIPAddress()
        print("IPAddress :: \(strIPAddress)")
        
        authIndicator.color = .white
        UIView.animate(withDuration: 0.3, animations:
                        {
                            self.authorizeButton.alpha = 0
                            self.errorAuthLabel.alpha = 0
                            self.authIndicator.alpha = 1
                        })
        authIndicator.startAnimating()
        
        Networking.sharedInstance.OpenrequestPOSTURL(params: (["params" : ["jsFingerPrint": userDevice?.first ?? "",
                                                                           "webGlId" : userDevice?.last ?? "" as Any,
                                                                           "platform": "iOS",
                                                                           "userAgent" : "Mozaika",
                                                                           "ip": strIPAddress,
                                                                           "cookieValue": "USE_DEVICE_ID",
                                                                           "username": username,
                                                                           "password": password],
                                                               "deviceId":""] as? [String:AnyObject]))
        {(result) in
            self.authIndicator.stopAnimating()
            self.authIndicator.alpha = 0
            switch result {
            
            case .Success(let data):
                self.view.isUserInteractionEnabled = true
                print(data)
                var warning:String = ""
                var reason:String = "Ошибка авторизации!"
                let warnLabel = self.errorAuthLabel!
                for itm in stride(from: 0, to: data.count, by: 1)
                {
                    let val = data[itm]
                    if let warn = val["warning"] as? String
                    {
                        warning = warn
                    }
                    else
                    {
                        if val["sessionID"] != nil
                        {
                            if UserDefaults.standard.bool(forKey: "saved") != true
                            {
                                UIView.animate(withDuration: 0.3, animations:
                                                {
                                                    self.replaceViews(side: true)
                                                })
                            }
                            else
                            {
                                UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                                    self.pinCodeView.frame.origin.x = -self.view.frame.width
                                }, completion: { [self] _ in
                                    
                                    loginButtonsView.alpha = 0
                                    loadData()
                                })
                            }
                        }
                    }
                }
                
                if warning.contains("password")
                {
                    reason = "Неверный логин или пароль!"
                }
                else if warning.contains("З_А_Б_Л_О_К_И_Р_О_В_А_Н")
                {
                    reason = "Пользователь заблокирован!"
                }
                else if warning.contains("ПОПЫТКА")
                {
                    reason = "Попытка подключения с разных станций!"
                }
                else if warning.contains("ВРЕМЕННЫХ")
                {
                    reason = "Нарушение временных ограничений!"
                }
                else if warning.contains("attempt")||warning.contains("postmaster")||warning.contains("SSL")
                {
                    reason = "Ошибка подключения!"
                }
                
                if warning != ""
                {
                    self.changeLabelText(text: reason, label: warnLabel)
                    
                }
                break
                
            case .Error( _):
                if UserDefaults.standard.bool(forKey: "saved") != true
                {
                self.changeLabelText(text: "Ошибка авторизации!", label:  self.errorAuthLabel!)
                }
                else
                {
                    self.authPinErrorShow()
                }
                self.view.isUserInteractionEnabled = true
                break
            case .NetworkError( _):
                if UserDefaults.standard.bool(forKey: "saved") != true
                {
                self.changeLabelText(text: "Ошибка сети", label:  self.errorAuthLabel!)
                }
                else
                {
                    self.authPinErrorShow()
                }
                self.view.isUserInteractionEnabled = true
                break
            case .LostConnection( _):
                if UserDefaults.standard.bool(forKey: "saved") != true
                {
                self.changeLabelText(text: "Потеря cоединения", label:  self.errorAuthLabel!)
                }
                else
                {
                    self.authPinErrorShow()
                }
                self.view.isUserInteractionEnabled = true
                break
            case .SessionTimeOut( _):
                if UserDefaults.standard.bool(forKey: "saved") != true
                {
                self.changeLabelText(text: "Время запроса истекло", label:  self.errorAuthLabel!)
                }
                else
                {
                    self.authPinErrorShow()
                }
                self.view.isUserInteractionEnabled = true
                break
            case .nilResponse( _):
                if UserDefaults.standard.bool(forKey: "saved") != true
                {
                self.changeLabelText(text: "Ошибка авторизации!", label:  self.errorAuthLabel!)
                }
                else
                {
                    self.authPinErrorShow()
                }
                self.view.isUserInteractionEnabled = true
                break
                
            }
        }
    }
 
    func authPinErrorShow()
    {
        self.changeLabelsAlpha(label: self.mRegError)
        self.resetPinIndicator()
    }
    func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
    
    func segueToTabBar() {
        performSegue(withIdentifier: "segueToMainView", sender: nil)
        self.pinCodeView.frame.origin.x = self.view.frame.width
    }
    
    @IBAction func unwindToLoginScreen(segue: UIStoryboardSegue) {
        guard segue.identifier == "unwindSegue" else { return }
        guard segue.source is AuthView else {return}
        print("done")
    }
    
}

enum Network: String {
    case wifi = "en0"
    
    case cellular = "pdp_ip0"
    case ipv4 = "ipv4"
    case ipv6 = "ipv6"
}



