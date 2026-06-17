//
//  ContentView.swift
//  MiniPlayerSwiftUI
//
//  Created by Aziz Bibitov on 17.06.2026.
//

import SwiftUI

// MARK: - Shared: Album Art + Track Info (iOS 18+)

struct TrackInfoView: View {
    var size: CGSize

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: size.height / 4)
                .fill(.blue.gradient)
                .frame(width: size.width, height: size.height)

            VStack(alignment: .leading, spacing: 6) {
                Text("Some Apple Music Title")
                    .font(.callout)
                    .lineLimit(1)
                Text("Some Artist Name")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - iOS 18+: Mini Player Bar

struct MiniPlayerView: View {
    var body: some View {
        HStack(spacing: 15) {
            TrackInfoView(size: .init(width: 30, height: 30))
            Spacer(minLength: 0)
            Button("", systemImage: "play.fill") {}
                .contentShape(.rect)
                .padding(.trailing, 10)
            Button("", systemImage: "forward.fill") {}
                .contentShape(.rect)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 15)
    }
}

// MARK: - iOS 18+: Expanded Full-Screen Player

struct ExpandedPlayerView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Capsule()
                    .fill(.secondary)
                    .frame(width: 35, height: 3)
                    .padding(.top, 10)

                HStack(spacing: 15) {
                    TrackInfoView(size: .init(width: 80, height: 80))
                    Spacer(minLength: 0)
                    Group {
                        Button("", systemImage: "star.circle.fill") {}
                        Button("", systemImage: "ellipsis.circle.fill") {}
                    }
                    .font(.title)
                    .foregroundStyle(.primary, Color.primary.opacity(0.1))
                }
                .padding(.horizontal, 15)

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

// MARK: - Pre-iOS 18: Blur background view

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Pre-iOS 18: Legacy Mini Player

struct LegacyMiniplayer: View {
    var animation: Namespace.ID
    @Binding var expand: Bool

    var height = UIScreen.main.bounds.height / 3
    var safeArea = UIApplication.shared.windows.first?.safeAreaInsets

    @State var volume: CGFloat = 0
    @State var offset: CGFloat = 0

    var body: some View {
        VStack {
            Capsule()
                .fill(Color.gray)
                .frame(width: expand ? 60 : 0, height: expand ? 4 : 0)
                .opacity(expand ? 1 : 0)
                .padding(.top, expand ? safeArea?.top : 0)
                .padding(.vertical, expand ? 30 : 0)

            HStack(spacing: 15) {
                if expand { Spacer(minLength: 0) }

                RoundedRectangle(cornerRadius: 15)
                    .fill(.blue.gradient)
                    .frame(width: expand ? height : 55, height: expand ? height : 55)
                    .cornerRadius(15)

                if !expand {
                    Text("Some Apple Music Title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .matchedGeometryEffect(id: "Label", in: animation)
                }

                Spacer(minLength: 0)

                if !expand {
                    Button(action: {}) {
                        Image(systemName: "play.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal)

            VStack(spacing: 15) {
                Spacer(minLength: 0)

                HStack {
                    if expand {
                        Text("Some Apple Music Title")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                            .matchedGeometryEffect(id: "Label", in: animation)
                    }

                    Spacer(minLength: 0)

                    Button(action: {}) {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .padding(.top, 20)

                HStack {
                    Capsule()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.primary.opacity(0.7), Color.primary.opacity(0.1)]),
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(height: 4)
                    Text("LIVE")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Capsule()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.primary.opacity(0.1), Color.primary.opacity(0.7)]),
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(height: 4)
                }
                .padding()

                Button(action: {}) {
                    Image(systemName: "stop.fill")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                }
                .padding()

                Spacer(minLength: 0)

                HStack(spacing: 15) {
                    Image(systemName: "speaker.fill")
                    Slider(value: $volume)
                    Image(systemName: "speaker.wave.2.fill")
                }
                .padding()

                HStack(spacing: 22) {
                    Button(action: {}) {
                        Image(systemName: "arrow.up.message")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Button(action: {}) {
                        Image(systemName: "airplayaudio")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Button(action: {}) {
                        Image(systemName: "list.bullet")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, safeArea?.bottom == 0 ? 15 : safeArea?.bottom)
            }
            .frame(height: expand ? nil : 0)
            .opacity(expand ? 1 : 0)
        }
        .frame(maxHeight: expand ? .infinity : 80)
        .background(
            VStack(spacing: 0) {
                BlurView()
                Divider()
            }
            .onTapGesture {
                withAnimation(.spring()) { expand = true }
            }
        )
        .cornerRadius(expand ? 20 : 0)
        .offset(y: expand ? 0 : -48)
        .offset(y: offset)
        .gesture(DragGesture().onEnded(onEnded(value:)).onChanged(onChanged(value:)))
        .ignoresSafeArea()
    }

    func onChanged(value: DragGesture.Value) {
        if value.translation.height > 0 && expand {
            offset = value.translation.height
        }
    }

    func onEnded(value: DragGesture.Value) {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.95)) {
            if value.translation.height > height {
                expand = false
            }
            offset = 0
        }
    }
}

// MARK: - Pre-iOS 18: Tab Container

struct LegacyTabContainer: View {
    @State var current = 0
    @State var expand = false
    @Namespace var animation

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TabView(selection: $current) {
                HomeView()
                    .tag(0)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                SearchView()
                    .tag(1)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                SettingsView()
                    .tag(2)
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
            LegacyMiniplayer(animation: animation, expand: $expand)
        }
    }
}

// MARK: - Tab Content Views

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .imageScale(.large)
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                Text("Home")
                    .font(.title2)
            }
            .navigationTitle("Home")
        }
    }
}

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {}
                .navigationTitle("Search")
                .searchable(text: $searchText, placement: .toolbar, prompt: "Search...")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "gearshape.fill")
                    .imageScale(.large)
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                Text("Settings")
                    .font(.title2)
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Root

struct ContentView: View {
    @State private var expandMiniPlayer = false
    @Namespace private var animation
    
    var body: some View {
        if #available(iOS 26, *) {
            // iOS 26+: native floating accessory above tab bar
            tabs
                .tabViewBottomAccessory { miniPlayerBar }
                .fullScreenCover(isPresented: $expandMiniPlayer) {
                    ExpandedPlayerView()
                        .navigationTransition(.zoom(sourceID: "MINIPLAYER", in: animation))
                }
        } else if #available(iOS 18, *) {
            // iOS 18+: ultraThinMaterial pill overlaid above tab bar
            tabs
                .overlay(alignment: .bottom) {
                    miniPlayerBar
                        .padding(.vertical, 8)
                        .background(
                            .ultraThinMaterial,
                            in: .rect(cornerRadius: 15, style: .continuous)
                        )
                        .offset(y: -60)
                        .padding(.horizontal, 15)
                        .ignoresSafeArea(.keyboard, edges: .all)
                }
                .fullScreenCover(isPresented: $expandMiniPlayer) {
                    ExpandedPlayerView()
                        .navigationTransition(.zoom(sourceID: "MINIPLAYER", in: animation))
                }
        } else {
            LegacyTabContainer()
        }
    }
    
    @available(iOS 18, *)
    @ViewBuilder
    private var tabs: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") { HomeView() }
            Tab("Search", systemImage: "magnifyingglass", role: .search) { SearchView() }
            Tab("Settings", systemImage: "gearshape.fill") { SettingsView() }
        }
    }
    
    @available(iOS 18, *)
    private var miniPlayerBar: some View {
        MiniPlayerView()
            .matchedTransitionSource(id: "MINIPLAYER", in: animation)
            .onTapGesture { expandMiniPlayer.toggle() }
    }
}

#Preview {
    ContentView()
}
