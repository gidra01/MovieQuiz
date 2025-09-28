import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .image
        imageView.accessibilityIdentifier = "Poster"
        counterLabel.isAccessibilityElement = true
        counterLabel.accessibilityIdentifier = "Index"
        yesButton.accessibilityIdentifier = "Yes"
        noButton.accessibilityIdentifier  = "No"
        
        presenter = MovieQuizPresenter(viewController: self)
        
        textLabel.isHidden = true
        questionTitleLabel.isHidden = true
        counterLabel.isHidden = true
        yesButton.isHidden = true
        noButton.isHidden = true
        imageView.isHidden = true
        
        showLoadingIndicator()
      
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked(sender)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked(sender)
    }
    
    
    func show(quiz step: QuizStepViewModel) {
        if let img = step.image {
            hideLoadingIndicator()
            
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
            yesButton.isEnabled = true
            noButton.isEnabled = true
            
            textLabel.isHidden = false
            questionTitleLabel.isHidden = false
            counterLabel.isHidden = false
            yesButton.isHidden = false
            noButton.isHidden = false
            imageView.isHidden = false
            
            UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) {
                self.imageView.image = img
                self.imageView.alpha = 1
                self.imageView.backgroundColor = .clear
            }
        } else {
            textLabel.isHidden = true
            questionTitleLabel.isHidden = true
            counterLabel.isHidden = true
            yesButton.isHidden = true
            noButton.isHidden = true
            imageView.isHidden = true
            showLoadingIndicator()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
            
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                    
                self.presenter.restartGame()
            }
            
        alert.addAction(action)
            
        self.present(alert, animated: true, completion: nil)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
                
            presenter.restartGame()
            }
        alertPresenter.show(in: self, model: model)
    }
    
}
