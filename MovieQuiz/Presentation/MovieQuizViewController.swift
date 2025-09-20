import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter = AlertPresenter()
    
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6
        let questionFactory = QuestionFactory() // 2
        questionFactory.delegate = self         // 3
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
    }
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }
    
    private func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true

    }
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.borderWidth = 8
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
        }
    }
    func show(quiz result: QuizResultsViewModel) {
        let best = statisticService.bestGame
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let bestDate = best.date.dateTimeString

        let message =
        """
        \(result.text)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(best.correct)/\(best.total)  (\(bestDate))
        Средняя точность: \(accuracy)%
        """
        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.restartGame()
            }
        
        alertPresenter.show(in: self, model: model)
    }
    private func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory.requestNextQuestion()
    }
    private func makeResultsMessage() {
        
    }
}
