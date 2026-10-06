import UIKit

struct Teacher {
    let id: UUID
    let name: String
    let department: String
    let initials: String
    let color: UIColor
    
    init(name: String, department: String, initials: String? = nil, color: UIColor) {
        self.id = UUID()
        self.name = name
        self.department = department
        if let initials = initials {
            self.initials = initials
        } else {
            let parts = name.split(separator: " ")
            let letters = parts.compactMap { $0.first }
            self.initials = String(letters.prefix(2)).uppercased()
        }
        self.color = color
    }
}

final class TeacherService {
    static let shared = TeacherService()
    
    private let teachers: [Teacher] = [
        Teacher(name: "John Doe", department: "Matemáticas", initials: "JD", color: UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)),
        Teacher(name: "Anna Smith", department: "Física", initials: "AS", color: UIColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)),
        Teacher(name: "Robert Johnson", department: "Química", initials: "RJ", color: UIColor(red: 0.204, green: 0.780, blue: 0.349, alpha: 1.0)),
        Teacher(name: "Maria Brown", department: "Biología", initials: "MB", color: UIColor(red: 0.345, green: 0.337, blue: 0.839, alpha: 1.0)),
        Teacher(name: "David Wilson", department: "Historia", initials: "DW", color: UIColor(red: 1.0, green: 0.176, blue: 0.333, alpha: 1.0)),
        Teacher(name: "Emily Garcia", department: "Literatura", initials: "EG", color: UIColor(red: 0.686, green: 0.322, blue: 0.871, alpha: 1.0)),
        Teacher(name: "Thomas Martinez", department: "Ciencias de la Computación", initials: "TM", color: UIColor(red: 0.0, green: 0.780, blue: 0.745, alpha: 1.0)),
        Teacher(name: "Laura Taylor", department: "Arte", initials: "LT", color: UIColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 1.0))
    ]
    
    func getAllTeachers() -> [Teacher] {
        return teachers
    }
    
    func searchTeachers(query: String) -> [Teacher] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            return teachers
        }
        return teachers.filter { teacher in
            teacher.name.lowercased().contains(trimmed) ||
            teacher.department.lowercased().contains(trimmed) ||
            teacher.initials.lowercased().contains(trimmed)
        }
    }
}

final class TeacherCell: UITableViewCell {
    static let reuseIdentifier = "CeldaDocente"
    
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    private let avatarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let programmaticInitialsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let programmaticNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let programmaticDepartmentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let programmaticArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        imageView.image = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: config)
        imageView.tintColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1.0)
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        
        if avatarView != nil { return }
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 3
        
        avatarContainer.addSubview(programmaticInitialsLabel)
        stack.addArrangedSubview(programmaticNameLabel)
        stack.addArrangedSubview(programmaticDepartmentLabel)
        
        contentView.addSubview(avatarContainer)
        contentView.addSubview(stack)
        contentView.addSubview(programmaticArrowImageView)
        
        NSLayoutConstraint.activate([
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            avatarContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 48),
            avatarContainer.heightAnchor.constraint(equalToConstant: 48),
            
            programmaticInitialsLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            programmaticInitialsLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            stack.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: programmaticArrowImageView.leadingAnchor, constant: -12),
            
            programmaticArrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            programmaticArrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            programmaticArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            programmaticArrowImageView.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    func configure(with teacher: Teacher) {
        let nameLbl = nameLabel ?? programmaticNameLabel
        let deptLbl = departmentLabel ?? programmaticDepartmentLabel
        let initLbl = initialsLabel ?? programmaticInitialsLabel
        let avView = avatarView ?? avatarContainer
        
        nameLbl.text = teacher.name
        deptLbl.text = teacher.department
        initLbl.text = teacher.initials
        initLbl.textColor = teacher.color
        avView.backgroundColor = teacher.color.withAlphaComponent(0.12)
        avView.layer.cornerRadius = 24
        avView.clipsToBounds = true
    }
}

class TeacherController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let teacherService = TeacherService.shared
    private var allTeachers: [Teacher] = []
    private var displayedTeachers: [Teacher] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAndTabs()
        setupUI()
        loadData()
        ensureResultsTabExists()
    }
    
    private func setupNavigationAndTabs() {
        title = "Docentes"
        navigationItem.title = "Docentes"
        navigationController?.navigationBar.prefersLargeTitles = false
        
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
        
        tabBarItem.title = "Lista"
        tabBarItem.image = UIImage(systemName: "rhombus.fill") ?? UIImage(systemName: "list.bullet")
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        if tableView == nil {
            if let existing = view.subviews.first(where: { $0 is UITableView }) as? UITableView {
                tableView = existing
            } else {
                let tv = UITableView(frame: .zero, style: .plain)
                tv.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(tv)
                tableView = tv
            }
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = tableView.superview {
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
        
        if searchBar == nil {
            if let existing = tableView.tableHeaderView as? UISearchBar {
                searchBar = existing
            } else if let sb = view.subviews.first(where: { $0 is UISearchBar }) as? UISearchBar {
                searchBar = sb
            }
        }
        
        if let searchBar = searchBar {
            searchBar.delegate = self
            searchBar.placeholder = "Buscar"
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundColor = .systemBackground
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
            searchBar.searchTextField.layer.cornerRadius = 10
            searchBar.searchTextField.layer.masksToBounds = true
            searchBar.searchTextField.textColor = .label
            searchBar.searchTextField.tintColor = .systemBlue
            
            searchBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 56)
            tableView.tableHeaderView = searchBar
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
        tableView.tableFooterView = UIView()
    }
    
    private func loadData() {
        allTeachers = teacherService.getAllTeachers()
        displayedTeachers = allTeachers
        tableView.reloadData()
    }
}

extension TeacherController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTeachers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeacherCell.reuseIdentifier, for: indexPath) as? TeacherCell else {
            let cell = TeacherCell(style: .default, reuseIdentifier: TeacherCell.reuseIdentifier)
            let teacher = displayedTeachers[indexPath.row]
            cell.configure(with: teacher)
            return cell
        }
        
        let teacher = displayedTeachers[indexPath.row]
        cell.configure(with: teacher)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TeacherController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        displayedTeachers = teacherService.searchTeachers(query: searchText)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        displayedTeachers = allTeachers
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
