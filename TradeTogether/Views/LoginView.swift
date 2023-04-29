//
//  LoginView.swift
//  TradeTogether
//
//  Created by Connor Joel on 4/23/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
    //E: joelc@bc.edu -- P: connor22
    //E: joelb@bc.edu -- P: connor23
    enum Field {
        case email, password
    }
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var buttonsDisabled = true
    @State private var path = NavigationPath()
    @State private var presentSheet = false
    @FocusState private var focusField: Field?
    
    var body: some View {
        NavigationStack (path: $path) {
            //App Logo
            ZStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .foregroundColor(Color("AccentColor"))
                Image(systemName: "person.3.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .padding(.top, 180)
                    .foregroundColor(Color("AccentColor"))
            }
            Text("Trade Together")
                .font(Font.custom("Futura", size: 50))
                .foregroundColor(Color("AccentColor"))
            
            Group {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focusField, equals: .email)
                    .onSubmit {
                        focusField = .password
                    }
                    .onChange(of: email) { _ in
                        enableButtons()
                    }
                
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .focused($focusField, equals: .password)
                    .onSubmit {
                        focusField = nil
                    }
                    .onChange(of: password) { _ in
                        enableButtons()
                    }
            }
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color("AccentColor"), lineWidth: 2)
            }
            .padding(.horizontal)
            
            HStack {
                Button("Sign Up") {
                    register()
                }
                .padding(.trailing, 10)
                
                Button("Log In") {
                    login()
                }
                .padding(.leading, 10)
            }
            .disabled(buttonsDisabled)
            .buttonStyle(.borderedProminent)
            .font(.title2)
            .padding(.top)
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                print("✅ Login Successful!")
                presentSheet = true
            }
        }
        .fullScreenCover(isPresented: $presentSheet) {
            HomeView()
        }
    }
    
    func enableButtons() {
        let emailIsGood = email.count >= 6 && email.contains("@")
        let passwordIsGood = password.count >= 6
        buttonsDisabled = !(emailIsGood && passwordIsGood)
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) {result, error in
            if let error = error {
                print("🛑 REGISTRATION ERROR: \(error.localizedDescription)")
                alertMessage = "REGISTRATION ERROR: \n\(error.localizedDescription)"
                showingAlert = true
            } else {
                print("✅ Registration Success!")
                presentSheet = true
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("🛑 LOGIN ERROR: \(error.localizedDescription)")
                alertMessage = "LOGIN ERROR: \n\(error.localizedDescription)"
                showingAlert = true
            } else {
                print("✅ Login Successful!")
                presentSheet = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
