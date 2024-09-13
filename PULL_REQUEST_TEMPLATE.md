### 1. Motivation
<!--
작업 동기에는 자신이 그 작업을 했던 이유를 적습니다.
예를 들어 다음과 같이 이슈 번호와 작업 이유를 함께 기재하는 형태로 작성합니다.

----------------------------------------------
Motivation
- #17 서브뷰 내부에 Audio spectrogram 렌더링
----------------------------------------------
-->

### 2. Key Changes
<!--
변경 사항에는 현재 소스코드가 기존 소스코드와는 어떻게 달라졌는지 적습니다.
구체적인 코드를 적기보다는 어떤 feature(코드∙기능∙함수∙메서드 등)가 추가∙변경∙삭제되었는지 적습니다.
예를 들어 다음과 같이 작성합니다.

----------------------------------------------
Key Changes
- SoundVisualizerView 내부에 SpectrogramView 렌더 로직 추가
- UI 깨짐 해결: SpectrogramView의 Contraints 조절
----------------------------------------------
-->

### 3. To Reviewers
<!--
리뷰하는 분께 항목에는 리뷰어가 주의깊게 보아야 하는 부분을 적습니다.
구체적인 코드보다는 리뷰할 코드블럭의 위치나 로직 정도만 적어주면 됩니다.
예를 들어 다음과 같이 작성합니다.

----------------------------------------------
To Reviewers
- SpectrogramView는 SpectrogramView.swift 파일에 있습니다.
- SpectrogramView를 불러오는 SoundVisualizerView는 SoundVisualizerView.swift 파일에 있습니다.
- SpectrogramView의 constraints는 SpectrogamViewController.swift로 분리했습니다.
- constraints 어느 부분이 잘못 됐는지 모르겠는데 원하는 위치에 렌더링되지 않아요. 도와줘...
----------------------------------------------
-->

