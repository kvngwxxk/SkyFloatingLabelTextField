//  Copyright 2016-2019 Skyscanner Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
//  with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
//  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
//  for the specific language governing permissions and limitations under the License.
import UIKit
import AudioToolbox

/**
 A beautiful and flexible textfield implementation with support for title label, error message and placeholder.
 */
@IBDesignable
open class SkyFloatingLabelTextField: UITextField { // swiftlint:disable:this type_body_length
    /**
     A Boolean value that determines if the language displayed is LTR.
     Default value set automatically from the application language settings.
     */
    @objc open var isLTRLanguage: Bool = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
        didSet {
            updateTextAligment()
        }
    }
    
    fileprivate func updateTextAligment() {
        if isLTRLanguage {
            textAlignment = .left
            titleLabel.textAlignment = .left
        } else {
            textAlignment = .left
            titleLabel.textAlignment = .left
        }
    }
    
    // MARK: Animation timing
    
    /// The value of the title appearing duration
    @objc dynamic open var titleFadeInDuration: TimeInterval = 0.2
    /// The value of the title disappearing duration
    @objc dynamic open var titleFadeOutDuration: TimeInterval = 0.3
    
    // MARK: Colors
    
    fileprivate var cachedTextColor: UIColor?
    
    /// A UIColor value that determines the text color of the editable text
    @IBInspectable
    override dynamic open var textColor: UIColor? {
        set {
            cachedTextColor = newValue
            updateControl(false)
        }
        get {
            return cachedTextColor
        }
    }
    
    /// A UIColor value that determines text color of the placeholder label
    @IBInspectable dynamic open var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            updatePlaceholder()
        }
    }
    
    /// A UIFont value that determines text color of the placeholder label
    @objc dynamic open var placeholderFont: UIFont? {
        didSet {
            updatePlaceholder()
        }
    }
    
    fileprivate func updatePlaceholder() {
        guard let placeholder = placeholder, let font = placeholderFont ?? font else {
            return
        }
        let color = isEnabled ? placeholderColor : disabledColor
        #if swift(>=4.2)
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font
            ]
        )
        #elseif swift(>=4.0)
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font
            ]
        )
        #else
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: font]
        )
        #endif
    }
    
    
    
    /// A UIFont value that determines the text font of the title label
    @objc dynamic open var titleFont: UIFont = .systemFont(ofSize: 13) {
        didSet {
            updateTitleLabel()
        }
    }
    
    @objc dynamic open var errorFont: UIFont = .systemFont(ofSize: 13) {
        didSet {
            updateErrorLabel()
        }
    }
    
    @objc dynamic open var isAvailableDeleteIcon: Bool = false {
        didSet {
            updateControl();
        }
    }
    
    /// A UIColor value that determines the text color of the title label when in the normal state
    @IBInspectable dynamic open var titleColor: UIColor = .gray {
        didSet {
            updateTitleColor()
        }
    }
    
    /// A UIColor value that determines the color of the bottom line when in the normal state
    @IBInspectable dynamic open var lineColor: UIColor = .lightGray {
        didSet {
            updateLineView()
        }
    }
    
    /// A UIColor value that determines the color used for the title label and line when the error message is not `nil`
    @IBInspectable dynamic open var errorColor: UIColor = .red {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the line when error message is not `nil`
    @IBInspectable dynamic open var lineErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the text when error message is not `nil`
    @IBInspectable dynamic open var textErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the title label when error message is not `nil`
    @IBInspectable dynamic open var titleErrorColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    /// A UIColor value that determines the color used for the title label and line when text field is disabled
    @IBInspectable dynamic open var disabledColor: UIColor = UIColor(white: 0.88, alpha: 1.0) {
        didSet {
            updateControl()
            updatePlaceholder()
        }
    }
    
    /// A UIColor value that determines the text color of the title label when editing
    @IBInspectable dynamic open var selectedTitleColor: UIColor = .blue {
        didSet {
            updateTitleColor()
        }
    }
    
    /// A UIColor value that determines the color of the line in a selected state
    @IBInspectable dynamic open var selectedLineColor: UIColor = .black {
        didSet {
            updateLineView()
        }
    }
    
    // MARK: Line height
    
    /// A CGFloat value that determines the height for the bottom line when the control is in the normal state
    @IBInspectable dynamic open var lineHeight: CGFloat = 2.0 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }
    
    /// A CGFloat value that determines the height for the bottom line when the control is in a selected state
    @IBInspectable dynamic open var selectedLineHeight: CGFloat = 2.0 {
        didSet {
            updateLineView()
            setNeedsDisplay()
        }
    }
    
    // MARK: View components
    
    /// The internal `UIView` to display the line below the text input.
    open var lineView: UIView!
    
    /// The internal `UILabel` that displays the selected, deselected title or error message based on the current state.
    open var titleLabel: UILabel!
    open var errorStringLabel : UILabel!
    open var dsecriptionStringLabel : UILabel!

    open var deleteBtnImage : UIImage! {
        didSet{
            deleteBtn.setBackgroundImage(deleteBtnImage, for: .normal)
        }
    }
    open var deleteBtn : UIButton!
    
    // MARK: Properties
    
    open var movingScrollView : UIScrollView = UIScrollView.init();
    open var parentsVC : UIViewController = UIViewController.init();
    open var isActivate : Bool = false;
    
    /**
     The formatter used before displaying content in the title label.
     This can be the `title`, `selectedTitle` or the `errorMessage`.
     The default implementation converts the text to uppercase.
     */
    open var titleFormatter: ((String) -> String) = { (text: String) -> String in
        if #available(iOS 9.0, *) {
            return text
        } else {
            return text
        }
    }
    
    /**
     Identifies whether the text object should hide the text being entered.
     */
    override open var isSecureTextEntry: Bool {
        set {
            super.isSecureTextEntry = newValue
            fixCaretPosition()

        }
        get {
            return super.isSecureTextEntry
        }
    }
    
    /// A String value for the error message to display.
    @IBInspectable
    open var errorMessage: String? {
        didSet {
            updateControl(true)
        }
        willSet(newVal){
            if(newVal != ""){
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }
        }
    }
    
    @IBInspectable
    open var descriptionMessage: String? {
        didSet {
            updateControl(true)
        }
    }
    
    /// A String value for the error message to display.
    @IBInspectable
    open var descriptionText: String? {
        didSet {
            updateControl(true)
        }
    }
    
    /// The backing property for the highlighted property
    fileprivate var _highlighted: Bool = false
    
    /**
     A Boolean value that determines whether the receiver is highlighted.
     When changing this value, highlighting will be done with animation
     */
    override open var isHighlighted: Bool {
        get {
            return _highlighted
        }
        set {
            _highlighted = newValue
            updateTitleColor()
            updateLineView()
        }
    }
    
    /// A Boolean value that determines whether the textfield is being edited or is selected.
    open var editingOrSelected: Bool {
        return super.isEditing || isSelected
    }
    
    /// A Boolean value that determines whether the receiver has an error message.
    open var hasErrorMessage: Bool {
        return errorMessage != nil && errorMessage != ""
    }
    
    open var hasDescriptionMessage: Bool {
        return descriptionMessage != nil && descriptionMessage != ""
    }
    
    fileprivate var _renderingInInterfaceBuilder: Bool = false
    
    /// The text content of the textfield
    @IBInspectable
    override open var text: String? {
        didSet {
            updateControl(false)
        }
    }
    
    /**
     The String to display when the input field is empty.
     The placeholder can also appear in the title label when both `title` `selectedTitle` and are `nil`.
     */
    @IBInspectable
    override open var placeholder: String? {
        didSet {
            setNeedsDisplay()
            updatePlaceholder()
            updateTitleLabel()
        }
    }
    
    /// The String to display when the textfield is editing and the input is not empty.
    @IBInspectable open var selectedTitle: String? {
        didSet {
            updateControl()
        }
    }
    
    /// The String to display when the textfield is not editing and the input is not empty.
    @IBInspectable open var title: String? {
        didSet {
            updateControl()
        }
    }
    
    // Determines whether the field is selected. When selected, the title floats above the textbox.
    open override var isSelected: Bool {
        didSet {
            updateControl(true)
        }
    }
    
    // MARK: - Initializers
    
    /**
     Initializes the control
     - parameter frame the frame of the control
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        init_SkyFloatingLabelTextField()
    }
    
    /**
     Intialzies the control by deserializing it
     - parameter aDecoder the object to deserialize the control from
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_SkyFloatingLabelTextField()
    }
    
    
    fileprivate final func init_SkyFloatingLabelTextField() {
        borderStyle = .none
        createTitleLabel()
        credateErrorLabel();
        createLineView()
        updateColors()
        addEditingChangedObserver()
        updateTextAligment()
        createDeleteButton();
        
    }
    
    fileprivate func addEditingChangedObserver() {
        self.addTarget(self, action: #selector(SkyFloatingLabelTextField.editingChanged), for: .editingChanged)
    }
    
    /**
     Invoked when the editing state of the textfield changes. Override to respond to this change.
     */
    @objc open func editingChanged() {
        updateControl(true)
        updateTitleLabel(true)
    }
    
    // MARK: create components
    
    fileprivate func createTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = titleFont
        titleLabel.alpha = 0.0
        titleLabel.textColor = titleColor
        
        addSubview(titleLabel)
        self.titleLabel = titleLabel
    }
    
    fileprivate func createDeleteButton() {
        
        let button = UIButton()
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        button.alpha = 0.0;
        button.isUserInteractionEnabled = true;
                
        self.rightView = button
        self.rightViewMode = .always;
        
        self.deleteBtn = button;
        
    }
    
    fileprivate func credateErrorLabel() {
        let eLabel = UILabel()
        eLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        eLabel.font = errorFont
        eLabel.alpha = 0.0
        eLabel.textColor = errorColor
        
        addSubview(eLabel)
        self.errorStringLabel = eLabel
    }
    
    fileprivate func createLineView() {
        
        if lineView == nil {
            let lineView = UIView()
            lineView.isUserInteractionEnabled = false
            self.lineView = lineView
            configureDefaultLineHeight()
        }
        
        lineView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(lineView)
    }
    
    fileprivate func configureDefaultLineHeight() {
        let onePixel: CGFloat = 1.0 / UIScreen.main.scale
        lineHeight = 2.0 * onePixel
        selectedLineHeight = 2.0 * self.lineHeight
    }
    
    // MARK: Responder handling
    
    /**
     Attempt the control to become the first responder
     - returns: True when successfull becoming the first responder
     */
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateControl(true)
        return result
    }
    
    /**
     Attempt the control to resign being the first responder
     - returns: True when successfull resigning being the first responder
     */
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateControl(true)
        return result
    }
    
    /// update colors when is enabled changed
    override open var isEnabled: Bool {
        didSet {
            updateControl()
            updatePlaceholder()
        }
    }
    
    // MARK: - View updates
    
    fileprivate func updateControl(_ animated: Bool = false) {
        updateColors()
        updateLineView()
        updateTitleLabel(animated)
        updateErrorLabel()
        updateDeleteBtn();
    }
    
    @objc func deleteAction(){
        self.text = "";
    }
    
    fileprivate func updateLineView() {
        guard let lineView = lineView else {
            return
        }
        
        lineView.frame = lineViewRectForBounds(bounds, editing: editingOrSelected)
        updateLineColor()
    }
    
    // MARK: - Color updates
    
    /// Update the colors for the control. Override to customize colors.
    open func updateColors() {
        updateLineColor()
        updateTitleColor()
        updateTextColor()
    }
    
    fileprivate func updateLineColor() {
        guard let lineView = lineView else {
            return
        }
        
        if !self.isEnabled {
            lineView.backgroundColor = self.disabledColor
        } else if self.hasErrorMessage {
            lineView.backgroundColor = self.lineErrorColor ?? self.errorColor
        } else {
            if(self.editingOrSelected){
                self.animate(view: lineView)
            }else{
                if let vl = lineView.layer.sublayers{
                    for v in vl{
                        v.removeFromSuperlayer();
                    }
                }
                lineView.backgroundColor = self.lineColor
            }
        }
        
        
    }
    
    func animate(view : UIView) {
        
        let path = UIBezierPath();
//        path.move(to: CGPoint.init(x: view.bounds.width/2, y: 0))
        path.move(to: CGPoint.init(x: view.bounds.width/2, y: view.bounds.height))
//        path.addLine(to: CGPoint.init(x: view.bounds.width, y: 0))
        path.addLine(to: CGPoint.init(x: 0, y: view.bounds.height))
        path.lineWidth = 2;
        
        let path2 = UIBezierPath();
//        path2.move(to: CGPoint.init(x: view.bounds.width/2, y: 0))
        path2.move(to: CGPoint.init(x: view.bounds.width/2, y: view.bounds.height))
//        path2.addLine(to: CGPoint.init(x: 0, y: 0))
        path2.addLine(to: CGPoint.init(x: view.bounds.width, y: view.bounds.height))
//        path2.lineWidth = 2;
        
        let anim = CABasicAnimation.init(keyPath: "strokeEnd");
        anim.fromValue = 0;
        anim.toValue = 1;
        anim.duration = 0.2
        
        let layer = CAShapeLayer()
        layer.frame = view.bounds;
        layer.path = path.cgPath;
        layer.fillColor = UIColor.gray.cgColor;
//        layer.strokeColor = UIColor.black.cgColor;
//        layer.lineWidth = 1.0;
        layer.strokeColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        layer.lineWidth = view.bounds.height
        layer.add(anim, forKey: "stroke");
        
        let layer2 = CAShapeLayer()
        layer2.frame = view.bounds;
        layer2.path = path2.cgPath;
        layer2.fillColor = UIColor.gray.cgColor;
//        layer2.strokeColor = UIColor.black.cgColor;
//        layer2.lineWidth = 1.0;
        layer2.strokeColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        layer2.lineWidth = view.bounds.height

        layer2.add(anim, forKey: "stroke2");
        
        
        view.layer.addSublayer(layer)
        view.layer.addSublayer(layer2)
        
    }
    
    fileprivate func updateTitleColor() {
        guard let titleLabel = titleLabel else {
            return
        }
        
        if !isEnabled {
            titleLabel.textColor = disabledColor
        } else {
            if editingOrSelected || isHighlighted {
                titleLabel.textColor = selectedTitleColor
            } else {
                titleLabel.textColor = titleColor
            }
        }
    }
    
    
    fileprivate func updateDeleteBtn(){
        
        guard let deleteBtn = deleteBtn else{
            return
        }
        
        if(isAvailableDeleteIcon){
            updateDeleteBtnVisibility();
        }else{
            updateDeleteBtnVisibility();
        }
    }
    
    
    fileprivate func updateTextColor() {
        if !isEnabled {
            super.textColor = disabledColor
        } else if hasErrorMessage {
            super.textColor = textErrorColor ?? errorColor
        } else {
            super.textColor = cachedTextColor
        }
    }
    
    // MARK: - Title handling
    
    fileprivate func updateTitleLabel(_ animated: Bool = false) {
        guard let titleLabel = titleLabel else {
            return
        }
        
        var titleText: String?
        if editingOrSelected {
            titleText = selectedTitleOrTitlePlaceholder()
            if titleText == nil {
                titleText = titleOrPlaceholder()
            }
        } else {
            titleText = titleOrPlaceholder()
        }
        
        
        titleLabel.text = titleText
        titleLabel.font = titleFont
        
        updateTitleVisibility(animated)
    }
    
    fileprivate func updateDescription(_ animated: Bool = false) {
        guard let errorLabel = errorStringLabel else {
            return
        }
        
        guard let message = descriptionMessage else{
            return
        }
        
        errorLabel.textColor = UIColor.init(red: 119/255.0, green: 119/255.0, blue: 119/255.0, alpha: 1.0);
        errorLabel.font = errorFont
        if(self.editingOrSelected){
            errorLabel.text = descriptionMessage
        }else{
            errorLabel.text = "";
        }
        
        
        updateErrorMessageVisibility();
    }
    
    fileprivate func updateErrorLabel(_ animated: Bool = false) {
        guard let errorLabel = errorStringLabel else {
            return
        }
        
        guard let message = errorMessage else{
            if hasDescriptionMessage {
                updateDescription();
            }
            return
        }
        
        errorLabel.text = message
        errorLabel.font = errorFont
        
        updateErrorMessageVisibility();
    }
    
    fileprivate var _titleVisible: Bool = false
    
    /*
     *   Set this value to make the title visible
     */
    open func setTitleVisible(
        _ titleVisible: Bool,
        animated: Bool = false,
        animationCompletion: ((_ completed: Bool) -> Void)? = nil
    ) {
        if _titleVisible == titleVisible {
            return
        }
        _titleVisible = titleVisible
        updateTitleColor()
        updateTitleVisibility(animated, completion: animationCompletion)
    }
    
    /**
     Returns whether the title is being displayed on the control.
     - returns: True if the title is displayed on the control, false otherwise.
     */
    open func isTitleVisible() -> Bool {
        if(isEditing){
            return false;
        }
        return hasText || hasErrorMessage || _titleVisible
    }
    
    open func isDeleteVisible() -> Bool {
        
        guard isAvailableDeleteIcon else{
            return false;
        }
        
        if(!isEditing){
            return false;
        }
        
        if let t = text{
            if(t.count <= 0){
                return false;
            }
        }
        
        return true;
    }
    
    fileprivate func updateTitleVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let alpha: CGFloat = isTitleVisible() ? 1.0 : 0.0
        let frame: CGRect = titleLabelRectForBounds(bounds, editing: isTitleVisible())
        let updateBlock = { () -> Void in
            self.titleLabel.alpha = alpha
            self.titleLabel.frame = frame
        }
        if animated {
            #if swift(>=4.2)
            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            #else
            let animationOptions: UIViewAnimationOptions = .curveEaseOut
            #endif
            let duration = isTitleVisible() ? titleFadeInDuration : titleFadeOutDuration
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: { () -> Void in
                updateBlock()
            }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    
    fileprivate func updateErrorMessageVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        let frame: CGRect = errorLabelRectForBounds(bounds)
        let updateBlock = { () -> Void in
            self.errorStringLabel.alpha = 1.0
            self.errorStringLabel.frame = frame
        }
        if animated {
            #if swift(>=4.2)
            let animationOptions: UIView.AnimationOptions = .curveEaseOut
            #else
            let animationOptions: UIViewAnimationOptions = .curveEaseOut
            #endif
            let duration = isTitleVisible() ? titleFadeInDuration : titleFadeOutDuration
            UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: { () -> Void in
                updateBlock()
            }, completion: completion)
        } else {
            updateBlock()
            completion?(true)
        }
    }
    
    fileprivate func updateDeleteBtnVisibility(_ animated: Bool = false, completion: ((_ completed: Bool) -> Void)? = nil) {
        if isDeleteVisible() {
            deleteBtn.alpha = 1.0
        }else{
            deleteBtn.alpha = 0.0
        }
        
    }
    
    // MARK: - UITextField text/placeholder positioning overrides
    
    /**
     Calculate the rectangle for the textfield when it is not being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)
        let titleHeight = self.titleHeight()
        
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight,
            width: superRect.size.width,
            height: superRect.size.height - titleHeight - selectedLineHeight
        )
        return rect
    }
    
    /**
     Calculate the rectangle for the textfield when it is being edited
     - parameter bounds: The current bounds of the field
     - returns: The rectangle that the textfield should render in
     */
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)
        let titleHeight = self.titleHeight()
        
        let rect = CGRect(
            x: superRect.origin.x,
            y: titleHeight,
            width: superRect.size.width,
            height: superRect.size.height - titleHeight - selectedLineHeight
        )
        return rect
    }
    
    /**
     Calculate the rectangle for the placeholder
     - parameter bounds: The current bounds of the placeholder
     - returns: The rectangle that the placeholder should render in
     */
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(
            x: 0,
            y: titleHeight(),
            width: bounds.size.width,
            height: bounds.size.height - titleHeight() - selectedLineHeight
        )
        return rect
    }
    
    // MARK: - Positioning Overrides
    
    /**
     Calculate the bounds for the title label. Override to create a custom size title field.
     - parameter bounds: The current bounds of the title
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the title label should render in
     */
    open func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        if editing {
            return CGRect(x: 0, y: 0, width: bounds.size.width, height: titleHeight())
        }
        return CGRect(x: 0, y: titleHeight(), width: bounds.size.width, height: titleHeight())
    }
    
    open func deleteLabelRectForBounds(_ bounds: CGRect) -> CGRect {
        //        return CGRect.init(origin: CGPoint.init(x: bounds.width - 16, y: bounds.height/2), size: CGSize.init(width: 18, height: 18))
        
        if isAvailableDeleteIcon {
            return CGRect.init(origin: CGPoint.init(x: bounds.width - 0, y:0), size: CGSize.init(width: 18, height: 18))
        }else{
            return CGRect.init(origin: CGPoint.init(x: 0, y:0), size: CGSize.init(width: 0, height: 0))
        }
        
    }
    
    open func errorLabelRectForBounds(_ bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: bounds.height + errorMessageHeight() - 10, width: bounds.size.width, height: (errorMessageHeight()))
    }
    
    /**
     Calculate the bounds for the bottom line of the control.
     Override to create a custom size bottom line in the textbox.
     - parameter bounds: The current bounds of the line
     - parameter editing: True if the control is selected or highlighted
     - returns: The rectangle that the line bar should render in
     */
    open func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let height = editing ? selectedLineHeight : lineHeight
        return CGRect(x: 0, y: bounds.size.height - height, width: bounds.size.width, height: height)
    }
    
    /**
     Calculate the height of the title label.
     -returns: the calculated height of the title label. Override to size the title with a different height
     */
    open func titleHeight() -> CGFloat {
        if let titleLabel = titleLabel,
            let font = titleLabel.font {
            return font.lineHeight
        }
        return 15.0
    }
    
    open func errorMessageHeight()-> CGFloat{
        if let errorLabel = errorStringLabel,
            let font = errorLabel.font {
            return font.lineHeight
        }
        return 8.0
    }
    
    
    /**
     Calcualte the height of the textfield.
     -returns: the calculated height of the textfield. Override to size the textfield with a different height
     */
    open func textHeight() -> CGFloat {
        guard let font = self.font else {
            return 0.0
        }
        
        return font.lineHeight + 7.0
    }
    
    // MARK: - Layout
    
    /// Invoked when the interface builder renders the control
    override open func prepareForInterfaceBuilder() {
        if #available(iOS 8.0, *) {
            super.prepareForInterfaceBuilder()
        }
        
        borderStyle = .none
        
        isSelected = true
        _renderingInInterfaceBuilder = true
        updateControl(false)
        invalidateIntrinsicContentSize()
    }
    
    
    
    /// Invoked by layoutIfNeeded automatically
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = titleLabelRectForBounds(bounds, editing: isTitleVisible() || _renderingInInterfaceBuilder)
        lineView.frame = lineViewRectForBounds(bounds, editing: editingOrSelected || _renderingInInterfaceBuilder)
        errorStringLabel.frame = errorLabelRectForBounds(bounds)
        
    }
    
    /**
     Calculate the content size for auto layout
     
     - returns: the content size to be used for auto layout
     */
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.size.width, height: titleHeight() + textHeight())
    }
    
    // MARK: - Helpers
    
    fileprivate func titleOrPlaceholder() -> String? {
        guard let title = title ?? placeholder else {
            return nil
        }
        return titleFormatter(title)
    }
    
    fileprivate func selectedTitleOrTitlePlaceholder() -> String? {
        guard let title = selectedTitle ?? title ?? placeholder else {
            return nil
        }
        return titleFormatter(title)
    }
    
    
}
