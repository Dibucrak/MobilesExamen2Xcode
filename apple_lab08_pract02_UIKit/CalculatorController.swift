import UIKit

enum MathOperationType: String, CaseIterable {
    case addition = "Suma (+)"
    case subtraction = "Resta (-)"
    case multiplication = "Multiplicación (×)"
    
    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "×"
        }
    }
    
    func calculate(first: Double, second: Double) -> Double {
        switch self {
        case .addition:
            return first + second
        case .subtraction:
            return first - second
        case .multiplication:
            return first * second
        }
    }
}

struct CalculationResult {
    let operation: MathOperationType
    let firstNumber: Double
    let secondNumber: Double
    let result: Double
    
    var formattedFirstNumber: String {
        return format(number: firstNumber)
    }
    
    var formattedSecondNumber: String {
        return format(number: secondNumber)
    }
    
    var formattedResult: String {
        return format(number: result)
    }
    
    private func format(number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", number)
        } else {
            return String(format: "%.2f", number)
        }
    }
}

final class CalculationService {
    static let shared = CalculationService()
    
    var latestResult: CalculationResult = CalculationResult(
        operation: .addition,
        firstNumber: 42,
        secondNumber: 28,
        result: 70
    )
    
    func performCalculation(first: Double, second: Double, operation: MathOperationType) -> CalculationResult {
        let res = operation.calculate(first: first, second: second)
        let calc = CalculationResult(operation: operation, firstNumber: first, secondNumber: second, result: res)
        self.latestResult = calc
        return calc
    }
}

class CalculatorController: UIViewController {

    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var selectedOperationLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var additionOptionLabel: UILabel!
    @IBOutlet weak var subtractionOptionLabel: UILabel!
    @IBOutlet weak var multiplicationOptionLabel: UILabel!
    @IBOutlet weak var optionsContainer: UIView!
    @IBOutlet weak var cardView: UIView!

    private var programmaticFirstTextField: UITextField?
    private var programmaticSecondTextField: UITextField?
    private var programmaticSelectedOperationLabel: UILabel?
    private var optionRows: [(type: MathOperationType, label: UILabel, view: UIView)] = []
    
    var selectedOperation: MathOperationType = .addition {
        didSet {
            updateSelectedOperationUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAndTabs()
        if cardView != nil || firstTextField != nil {
            configureStoryboardUI()
        } else {
            setupProgrammaticUI()
        }
        updateSelectedOperationUI()
        setupKeyboardDismiss()
        ensureResultsTabExists()
    }
    
    private func setupNavigationAndTabs() {
        title = "Calculadora"
        navigationItem.title = "Calculadora"
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        tabBarItem.title = "Calculadora"
        tabBarItem.image = UIImage(systemName: "rhombus")
    }
    
    private func ensureResultsTabExists() {
        guard let tbc = tabBarController else { return }
        var currentVCs = tbc.viewControllers ?? []
        if currentVCs.count == 2 {
            let resultsVC = ResultController()
            let navVC = UINavigationController(rootViewController: resultsVC)
            navVC.tabBarItem = UITabBarItem(title: "Resultados", image: UIImage(systemName: "equal"), tag: 2)
            currentVCs.append(navVC)
            tbc.setViewControllers(currentVCs, animated: false)
        }
    }
    
    private func configureStoryboardUI() {
        cardView?.layer.cornerRadius = 10
        cardView?.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        cardView?.layer.borderWidth = 1
        cardView?.layer.masksToBounds = true
        
        optionsContainer?.layer.cornerRadius = 8
        optionsContainer?.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        optionsContainer?.layer.borderWidth = 1
        optionsContainer?.layer.masksToBounds = true
        
        calculateButton?.setTitle("Calcular", for: .normal)
        calculateButton?.layer.cornerRadius = 25
        calculateButton?.layer.masksToBounds = true
        calculateButton?.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        
        if let optContainer = optionsContainer {
            for sub in optContainer.subviews {
                if let tapGesture = sub.gestureRecognizers?.first as? UITapGestureRecognizer {
                    sub.removeGestureRecognizer(tapGesture)
                }
            }
            if let addLbl = additionOptionLabel, let addParent = addLbl.superview {
                addLbl.text = MathOperationType.addition.rawValue
                let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
                addParent.addGestureRecognizer(tap)
                addParent.tag = 0
                optionRows.append((type: .addition, label: addLbl, view: addParent))
            }
            if let subLbl = subtractionOptionLabel, let subParent = subLbl.superview {
                subLbl.text = MathOperationType.subtraction.rawValue
                let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
                subParent.addGestureRecognizer(tap)
                subParent.tag = 1
                optionRows.append((type: .subtraction, label: subLbl, view: subParent))
            }
            if let mulLbl = multiplicationOptionLabel, let mulParent = mulLbl.superview {
                mulLbl.text = MathOperationType.multiplication.rawValue
                let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
                mulParent.addGestureRecognizer(tap)
                mulParent.tag = 2
                optionRows.append((type: .multiplication, label: mulLbl, view: mulParent))
            }
        }
    }

    private func setupProgrammaticUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        let localCardView = UIView()
        let titleLabel = UILabel()
        
        let firstContainer = UIView()
        let firstTitle = UILabel()
        let firstDiv = UIView()
        let firstTF = UITextField()
        
        let secondContainer = UIView()
        let secondTitle = UILabel()
        let secondDiv = UIView()
        let secondTF = UITextField()
        
        let opContainer = UIView()
        let opTitle = UILabel()
        let opDiv = UIView()
        let opLabel = UILabel()
        let arrowView = UIImageView()
        
        let localOptionsContainer = UIView()
        let localCalcBtn = UIButton(type: .system)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        localCardView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(localCardView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            localCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            localCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            localCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            localCardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
        
        localCardView.backgroundColor = .systemBackground
        localCardView.layer.cornerRadius = 10
        localCardView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        localCardView.layer.borderWidth = 1
        localCardView.layer.masksToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Operación Matemática"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        localCardView.addSubview(titleLabel)
        
        setupFieldBox(container: firstContainer, titleLabel: firstTitle, divider: firstDiv, textField: firstTF, title: "Primer Número", defaultText: "0", parent: localCardView)
        setupFieldBox(container: secondContainer, titleLabel: secondTitle, divider: secondDiv, textField: secondTF, title: "Segundo Número", defaultText: "0", parent: localCardView)
        
        programmaticFirstTextField = firstTF
        programmaticSecondTextField = secondTF
        programmaticSelectedOperationLabel = opLabel
        
        opContainer.translatesAutoresizingMaskIntoConstraints = false
        opContainer.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        opContainer.layer.cornerRadius = 8
        opContainer.layer.masksToBounds = true
        localCardView.addSubview(opContainer)
        
        opTitle.translatesAutoresizingMaskIntoConstraints = false
        opTitle.text = "Operación"
        opTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        opTitle.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        opContainer.addSubview(opTitle)
        
        opDiv.translatesAutoresizingMaskIntoConstraints = false
        opDiv.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        opContainer.addSubview(opDiv)
        
        opLabel.translatesAutoresizingMaskIntoConstraints = false
        opLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        opLabel.textColor = .label
        opLabel.text = selectedOperation.rawValue
        opContainer.addSubview(opLabel)
        
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.contentMode = .scaleAspectFit
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        arrowView.image = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: config)
        arrowView.tintColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        opContainer.addSubview(arrowView)
        
        NSLayoutConstraint.activate([
            opTitle.topAnchor.constraint(equalTo: opContainer.topAnchor, constant: 7),
            opTitle.leadingAnchor.constraint(equalTo: opContainer.leadingAnchor, constant: 12),
            opTitle.trailingAnchor.constraint(equalTo: opContainer.trailingAnchor, constant: -12),
            
            opDiv.topAnchor.constraint(equalTo: opTitle.bottomAnchor, constant: 4),
            opDiv.leadingAnchor.constraint(equalTo: opContainer.leadingAnchor, constant: 12),
            opDiv.trailingAnchor.constraint(equalTo: opContainer.trailingAnchor, constant: -12),
            opDiv.heightAnchor.constraint(equalToConstant: 1),
            
            opLabel.topAnchor.constraint(equalTo: opDiv.bottomAnchor, constant: 3),
            opLabel.leadingAnchor.constraint(equalTo: opContainer.leadingAnchor, constant: 12),
            opLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8),
            opLabel.bottomAnchor.constraint(equalTo: opContainer.bottomAnchor, constant: -5),
            
            arrowView.centerYAnchor.constraint(equalTo: opLabel.centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: opContainer.trailingAnchor, constant: -12),
            arrowView.widthAnchor.constraint(equalToConstant: 12),
            arrowView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        localOptionsContainer.translatesAutoresizingMaskIntoConstraints = false
        localOptionsContainer.backgroundColor = .systemBackground
        localOptionsContainer.layer.cornerRadius = 8
        localOptionsContainer.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        localOptionsContainer.layer.borderWidth = 1
        localOptionsContainer.layer.masksToBounds = true
        localCardView.addSubview(localOptionsContainer)
        
        optionRows.removeAll()
        var prevRow: UIView? = nil
        for (idx, op) in MathOperationType.allCases.enumerated() {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false
            localOptionsContainer.addSubview(row)
            
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = op.rawValue
            lbl.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            row.addSubview(lbl)
            
            NSLayoutConstraint.activate([
                lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
                lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                lbl.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -14),
                row.leadingAnchor.constraint(equalTo: localOptionsContainer.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: localOptionsContainer.trailingAnchor),
                row.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            if let p = prevRow {
                let div = UIView()
                div.translatesAutoresizingMaskIntoConstraints = false
                div.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
                localOptionsContainer.addSubview(div)
                NSLayoutConstraint.activate([
                    div.topAnchor.constraint(equalTo: p.bottomAnchor),
                    div.leadingAnchor.constraint(equalTo: localOptionsContainer.leadingAnchor),
                    div.trailingAnchor.constraint(equalTo: localOptionsContainer.trailingAnchor),
                    div.heightAnchor.constraint(equalToConstant: 1),
                    row.topAnchor.constraint(equalTo: div.bottomAnchor)
                ])
            } else {
                row.topAnchor.constraint(equalTo: localOptionsContainer.topAnchor).isActive = true
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            row.addGestureRecognizer(tap)
            row.tag = idx
            optionRows.append((type: op, label: lbl, view: row))
            prevRow = row
        }
        prevRow?.bottomAnchor.constraint(equalTo: localOptionsContainer.bottomAnchor).isActive = true
        
        localCalcBtn.translatesAutoresizingMaskIntoConstraints = false
        localCalcBtn.setTitle("Calcular", for: .normal)
        localCalcBtn.setTitleColor(.white, for: .normal)
        localCalcBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        localCalcBtn.backgroundColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)
        localCalcBtn.layer.cornerRadius = 25
        localCalcBtn.layer.masksToBounds = true
        localCalcBtn.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
        localCardView.addSubview(localCalcBtn)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: localCardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -16),
            
            firstContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            firstContainer.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 16),
            firstContainer.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -16),
            firstContainer.heightAnchor.constraint(equalToConstant: 62),
            
            secondContainer.topAnchor.constraint(equalTo: firstContainer.bottomAnchor, constant: 14),
            secondContainer.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 16),
            secondContainer.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -16),
            secondContainer.heightAnchor.constraint(equalToConstant: 62),
            
            opContainer.topAnchor.constraint(equalTo: secondContainer.bottomAnchor, constant: 14),
            opContainer.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 16),
            opContainer.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -16),
            opContainer.heightAnchor.constraint(equalToConstant: 62),
            
            localOptionsContainer.topAnchor.constraint(equalTo: opContainer.bottomAnchor, constant: 4),
            localOptionsContainer.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 16),
            localOptionsContainer.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -16),
            
            localCalcBtn.topAnchor.constraint(equalTo: localOptionsContainer.bottomAnchor, constant: 22),
            localCalcBtn.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 16),
            localCalcBtn.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -16),
            localCalcBtn.heightAnchor.constraint(equalToConstant: 50),
            localCalcBtn.bottomAnchor.constraint(equalTo: localCardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupFieldBox(container: UIView, titleLabel: UILabel, divider: UIView, textField: UITextField, title: String, defaultText: String, parent: UIView) {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        container.layer.cornerRadius = 8
        container.layer.masksToBounds = true
        parent.addSubview(container)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        container.addSubview(titleLabel)
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        container.addSubview(divider)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = defaultText
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .label
        textField.keyboardType = .decimalPad
        container.addSubview(textField)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            divider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            textField.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 3),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5)
        ])
    }
    
    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let targetView = sender.view, targetView.tag < MathOperationType.allCases.count else { return }
        selectedOperation = MathOperationType.allCases[targetView.tag]
    }
    
    private func updateSelectedOperationUI() {
        let label = selectedOperationLabel ?? programmaticSelectedOperationLabel
        label?.text = selectedOperation.rawValue
        
        for item in optionRows {
            if item.type == selectedOperation {
                item.label.textColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)
                item.label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            } else {
                item.label.textColor = .label
                item.label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        }
    }
    
    @objc private func calculateTapped() {
        view.endEditing(true)
        
        let tf1 = firstTextField ?? programmaticFirstTextField
        let tf2 = secondTextField ?? programmaticSecondTextField
        
        let firstNumText = tf1?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let secondNumText = tf2?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let firstVal = Double(firstNumText) ?? 0.0
        let secondVal = Double(secondNumText) ?? 0.0
        
        let result = CalculationService.shared.performCalculation(first: firstVal, second: secondVal, operation: selectedOperation)
        
        let resultVC = ResultController(result: result)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func resetForm() {
        let tf1 = firstTextField ?? programmaticFirstTextField
        let tf2 = secondTextField ?? programmaticSecondTextField
        tf1?.text = "0"
        tf2?.text = "0"
        selectedOperation = .addition
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ResultController: UIViewController {

    var calculationResult: CalculationResult?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var operationValLabel: UILabel!
    @IBOutlet weak var firstValLabel: UILabel!
    @IBOutlet weak var secondValLabel: UILabel!
    @IBOutlet weak var resultValueLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var newCalculationButton: UIButton!

    private var programmaticOperationValLabel: UILabel?
    private var programmaticFirstValLabel: UILabel?
    private var programmaticSecondValLabel: UILabel?
    private var programmaticResultValueLabel: UILabel?

    init(result: CalculationResult? = nil) {
        self.calculationResult = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAndTabs()
        if cardView != nil || resultValueLabel != nil {
            configureStoryboardUI()
        } else {
            setupProgrammaticUI()
        }
        displayData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if calculationResult == nil {
            calculationResult = CalculationService.shared.latestResult
        }
        displayData()
    }
    
    private func setupNavigationAndTabs() {
        title = "Resultado"
        navigationItem.title = "Resultado"
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        tabBarItem.title = "Resultados"
        tabBarItem.image = UIImage(systemName: "equal")
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backButton.tintColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else if let tbc = tabBarController {
            tbc.selectedIndex = 1
        } else {
            dismiss(animated: true)
        }
    }
    
    private func configureStoryboardUI() {
        cardView?.layer.cornerRadius = 10
        cardView?.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        cardView?.layer.borderWidth = 1
        cardView?.layer.masksToBounds = true
        
        shareButton?.setTitle("Compartir", for: .normal)
        shareButton?.layer.cornerRadius = 20
        shareButton?.layer.masksToBounds = true
        shareButton?.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        newCalculationButton?.setTitle("Nuevo Cálculo", for: .normal)
        newCalculationButton?.layer.cornerRadius = 20
        newCalculationButton?.layer.borderColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0).cgColor
        newCalculationButton?.layer.borderWidth = 2
        newCalculationButton?.layer.masksToBounds = true
        newCalculationButton?.addTarget(self, action: #selector(newCalculationTapped), for: .touchUpInside)
    }

    private func setupProgrammaticUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        let localCardView = UIView()
        let titleLabel = UILabel()
        
        let opRow = UIView()
        let opTitle = UILabel()
        let opValue = UILabel()
        
        let firstRow = UIView()
        let firstTitle = UILabel()
        let firstValue = UILabel()
        
        let secondRow = UIView()
        let secondTitle = UILabel()
        let secondValue = UILabel()
        
        let divider = UIView()
        let resultHeader = UILabel()
        let resultBox = UIView()
        let resultVal = UILabel()
        
        let buttonStack = UIStackView()
        let sBtn = UIButton(type: .system)
        let nBtn = UIButton(type: .system)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        localCardView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(localCardView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            localCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            localCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            localCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            localCardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
        
        localCardView.backgroundColor = .systemBackground
        localCardView.layer.cornerRadius = 10
        localCardView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        localCardView.layer.borderWidth = 1
        localCardView.layer.masksToBounds = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Resultado del Cálculo"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        localCardView.addSubview(titleLabel)
        
        setupDetailRow(container: opRow, titleLabel: opTitle, valueLabel: opValue, title: "Operación:", parent: localCardView)
        setupDetailRow(container: firstRow, titleLabel: firstTitle, valueLabel: firstValue, title: "Primer Número:", parent: localCardView)
        setupDetailRow(container: secondRow, titleLabel: secondTitle, valueLabel: secondValue, title: "Segundo Número:", parent: localCardView)
        
        programmaticOperationValLabel = opValue
        programmaticFirstValLabel = firstValue
        programmaticSecondValLabel = secondValue
        
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        localCardView.addSubview(divider)
        
        resultHeader.translatesAutoresizingMaskIntoConstraints = false
        resultHeader.text = "Resultado:"
        resultHeader.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        resultHeader.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        localCardView.addSubview(resultHeader)
        
        resultBox.translatesAutoresizingMaskIntoConstraints = false
        resultBox.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        resultBox.layer.cornerRadius = 10
        resultBox.layer.masksToBounds = true
        localCardView.addSubview(resultBox)
        
        resultVal.translatesAutoresizingMaskIntoConstraints = false
        resultVal.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        resultVal.textColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)
        resultVal.textAlignment = .center
        resultBox.addSubview(resultVal)
        programmaticResultValueLabel = resultVal
        
        NSLayoutConstraint.activate([
            resultVal.centerXAnchor.constraint(equalTo: resultBox.centerXAnchor),
            resultVal.centerYAnchor.constraint(equalTo: resultBox.centerYAnchor)
        ])
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        localCardView.addSubview(buttonStack)
        
        sBtn.setTitle("Compartir", for: .normal)
        sBtn.setTitleColor(.white, for: .normal)
        sBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sBtn.backgroundColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0)
        sBtn.layer.cornerRadius = 20
        sBtn.layer.masksToBounds = true
        sBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sBtn.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(sBtn)
        
        nBtn.setTitle("Nuevo Cálculo", for: .normal)
        nBtn.setTitleColor(UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0), for: .normal)
        nBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nBtn.backgroundColor = .systemBackground
        nBtn.layer.cornerRadius = 20
        nBtn.layer.borderColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1.0).cgColor
        nBtn.layer.borderWidth = 2
        nBtn.layer.masksToBounds = true
        nBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        nBtn.addTarget(self, action: #selector(newCalculationTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(nBtn)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: localCardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -16),
            
            opRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            opRow.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 20),
            opRow.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -20),
            opRow.heightAnchor.constraint(equalToConstant: 24),
            
            firstRow.topAnchor.constraint(equalTo: opRow.bottomAnchor, constant: 14),
            firstRow.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 20),
            firstRow.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -20),
            firstRow.heightAnchor.constraint(equalToConstant: 24),
            
            secondRow.topAnchor.constraint(equalTo: firstRow.bottomAnchor, constant: 14),
            secondRow.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 20),
            secondRow.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -20),
            secondRow.heightAnchor.constraint(equalToConstant: 24),
            
            divider.topAnchor.constraint(equalTo: secondRow.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            resultHeader.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            resultHeader.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 20),
            resultHeader.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -20),
            
            resultBox.topAnchor.constraint(equalTo: resultHeader.bottomAnchor, constant: 8),
            resultBox.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 20),
            resultBox.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -20),
            resultBox.heightAnchor.constraint(equalToConstant: 80),
            
            buttonStack.topAnchor.constraint(equalTo: resultBox.bottomAnchor, constant: 24),
            buttonStack.leadingAnchor.constraint(equalTo: localCardView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: localCardView.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: localCardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupDetailRow(container: UIView, titleLabel: UILabel, valueLabel: UILabel, title: String, parent: UIView) {
        container.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(container)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        container.addSubview(titleLabel)
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .left
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 140),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
    
    private func displayData() {
        guard let current = calculationResult ?? CalculationService.shared.latestResult as CalculationResult? else { return }
        
        let opLbl = operationValLabel ?? programmaticOperationValLabel
        let fLbl = firstValLabel ?? programmaticFirstValLabel
        let sLbl = secondValLabel ?? programmaticSecondValLabel
        let rLbl = resultValueLabel ?? programmaticResultValueLabel
        
        opLbl?.text = current.operation.rawValue
        fLbl?.text = current.formattedFirstNumber
        sLbl?.text = current.formattedSecondNumber
        rLbl?.text = current.formattedResult
    }
    
    @objc private func shareTapped() {
        guard let current = calculationResult ?? CalculationService.shared.latestResult as CalculationResult? else { return }
        let shareText = "Resultado del cálculo: \(current.formattedFirstNumber) \(current.operation.symbol) \(current.formattedSecondNumber) = \(current.formattedResult)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton ?? view
            popover.sourceRect = (shareButton ?? view).bounds
        }
        present(activityVC, animated: true)
    }
    
    @objc private func newCalculationTapped() {
        if let nav = navigationController {
            if let calcVC = nav.viewControllers.first(where: { $0 is CalculatorController }) as? CalculatorController {
                calcVC.resetForm()
                nav.popToViewController(calcVC, animated: true)
                return
            }
        }
        if let tbc = tabBarController {
            if let vcs = tbc.viewControllers {
                for vc in vcs {
                    if let nav = vc as? UINavigationController, let calcVC = nav.viewControllers.first as? CalculatorController {
                        calcVC.resetForm()
                        break
                    } else if let calcVC = vc as? CalculatorController {
                        calcVC.resetForm()
                        break
                    }
                }
            }
            tbc.selectedIndex = 1
        } else {
            dismiss(animated: true)
        }
    }
}
