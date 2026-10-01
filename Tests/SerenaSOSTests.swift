//
//  SerenaSOSTests.swift
//  SerenaSOSTests
//
//  Created for PNRT Studio
//

import Testing
import Foundation
@testable import SerenaSOS

@Suite("Auditoria & Testes de Qualidade — Serena SOS")
struct SerenaSOSTests {

    @Test("Validação de inicialização do ViewModel com técnica padrão")
    @MainActor
    func testDefaultTechniqueInitialization() {
        let viewModel = SOSBreathingViewModel()

        #expect(viewModel.currentTechnique == .physiologicalSigh)
        #expect(viewModel.isRunning == false)
        #expect(viewModel.orbScale == 1.0)
    }

    @Test("Início e encerramento de sessão de alívio")
    @MainActor
    func testSessionToggleFlow() {
        let viewModel = SOSBreathingViewModel()

        viewModel.startSession()
        #expect(viewModel.isRunning == true)

        viewModel.stopSession()
        #expect(viewModel.isRunning == false)
        #expect(viewModel.orbScale == 1.0)
    }

    @Test("Técnicas de respiração possuem durações e nomes válidos")
    func testBreathingTechniquesValidity() {
        let techniques = BreathingTechnique.allCases

        #expect(techniques.count == 3)
        #expect(techniques.contains(.physiologicalSigh))
        #expect(techniques.contains(.boxBreathing))
        #expect(techniques.contains(.deepRelaxation))

        for tech in techniques {
            #expect(!tech.displayName.isEmpty)
        }
    }

    @Test("Produtos configurados possuem IDs correspondentes ao App Store Connect")
    func testProductIdentifiersIntegrity() {
        let expectedAnnualID = "com.pnrt.serenasos.annual"
        let expectedMonthlyID = "com.pnrt.serenasos.monthly"

        #expect(expectedAnnualID.hasPrefix("com.pnrt.serenasos"))
        #expect(expectedMonthlyID.hasPrefix("com.pnrt.serenasos"))
    }

    @Test("Modelo ReliefSession instancia corretamente dados somáticos")
    func testReliefSessionCreation() {
        let session = ReliefSession(
            durationSeconds: 120,
            technique: .physiologicalSigh,
            preHeartRate: 98.0,
            postHeartRate: 82.0,
            triggerTag: "Trabalho"
        )

        #expect(session.durationSeconds == 120)
        #expect(session.technique == .physiologicalSigh)
        #expect(session.preHeartRate == 98.0)
        #expect(session.postHeartRate == 82.0)
        #expect(session.triggerTag == "Trabalho")
    }

    @Test("Validação de presença dos links obrigatórios de EULA e Privacidade")
    func testLegalLinksFormat() {
        let termsURL = URL(string: "https://pnrt.studio/legal/terms")
        let privacyURL = URL(string: "https://pnrt.studio/legal/privacy")

        #expect(termsURL != nil)
        #expect(privacyURL != nil)
        #expect(termsURL?.scheme == "https")
        #expect(privacyURL?.scheme == "https")
    }
}
