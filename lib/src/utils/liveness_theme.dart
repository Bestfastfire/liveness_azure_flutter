class LivenessTheme{
  final String feedbackNone;
  final String feedbackLookAtCamera;
  final String feedbackFaceNotCentered;
  final String feedbackMoveCloser;
  final String feedbackContinueToMoveCloser;
  final String feedbackMoveBack;
  final String feedbackReduceMovement;
  final String feedbackSmile;
  final String feedbackAttentionNotNeeded;

  Map<String, String> get asMap => {
    'feedback_none': feedbackNone,
    'feedback_look_at_camera': feedbackLookAtCamera,
    'feedback_face_not_centered': feedbackFaceNotCentered,
    'feedback_move_closer': feedbackMoveCloser,
    'feedback_continue_to_move_closer': feedbackContinueToMoveCloser,
    'feedback_move_back': feedbackMoveBack,
    'feedback_reduce_movement': feedbackReduceMovement,
    'feedback_smile': feedbackSmile,
    'feedback_attention_not_needed': feedbackAttentionNotNeeded
  };

  const LivenessTheme({
    this.feedbackNone = 'Hold Still.',
    this.feedbackLookAtCamera = 'Look at camera.',
    this.feedbackFaceNotCentered = 'Center your face in the circle.',
    this.feedbackMoveCloser = 'Too far away! Move in closer.',
    this.feedbackContinueToMoveCloser = 'Continue to move closer.',
    this.feedbackMoveBack = 'Too close! Move farther away.',
    this.feedbackReduceMovement = 'Too much movement.',
    this.feedbackSmile = 'Smile for the camera!',
    this.feedbackAttentionNotNeeded = 'Done, finishing up...'});

  factory LivenessTheme.pt({
    String feedbackNone = 'Fique Parado',
    String feedbackLookAtCamera = 'Olhe para a câmera.',
    String feedbackFaceNotCentered = 'Centralize seu rosto no círculo.',
    String feedbackMoveCloser = 'Muito longe! Chegue mais perto.',
    String feedbackContinueToMoveCloser = 'Continue se aproximando.',
    String feedbackMoveBack = 'Muito perto! Afaste-se mais.',
    String feedbackReduceMovement = 'Muito movimento.',
    String feedbackSmile = 'Sorria para a câmera!',
    String feedbackAttentionNotNeeded = 'Pronto, finalizando...'
  }){
    return LivenessTheme(
      feedbackNone: feedbackNone,
      feedbackLookAtCamera: feedbackLookAtCamera,
      feedbackFaceNotCentered: feedbackFaceNotCentered,
      feedbackMoveCloser: feedbackMoveCloser,
      feedbackContinueToMoveCloser: feedbackContinueToMoveCloser,
      feedbackMoveBack: feedbackMoveBack,
      feedbackReduceMovement: feedbackReduceMovement,
      feedbackSmile: feedbackSmile,
      feedbackAttentionNotNeeded: feedbackAttentionNotNeeded);
  }
}