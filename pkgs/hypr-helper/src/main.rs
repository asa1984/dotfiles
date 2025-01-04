use clap::{Parser, Subcommand};

use hyprland::data::{FullscreenState, Workspace};
use hyprland::dispatch::{
    Direction, Dispatch, DispatchType, FullscreenType, MonitorIdentifier, WindowIdentifier,
};
use hyprland::event_listener::EventListener;
use hyprland::shared::{HyprData, HyprDataActive};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    subcommands: Subcommands,
}

#[derive(Subcommand, Debug)]
enum Subcommands {
    /// Launch the event listener
    Start,

    /// Better move focus
    Movefocus {
        #[command(subcommand)]
        direction: MoveFocusDirection,
    },
}

#[derive(Subcommand, Debug)]
enum MoveFocusDirection {
    Up,
    Down,
    Left,
    Right,
}

fn force_fullscreen() -> hyprland::Result<()> {
    let is_fullscreen = FullscreenState::get()?.bool();
    if !is_fullscreen {
        Dispatch::call(DispatchType::ToggleFullscreen(FullscreenType::NoParam))?;
    }
    Ok(())
}

fn force_windowed() -> hyprland::Result<()> {
    let is_fullscreen = FullscreenState::get()?.bool();
    if is_fullscreen {
        Dispatch::call(DispatchType::ToggleFullscreen(FullscreenType::NoParam))?;
    }
    Ok(())
}

fn listen() -> hyprland::Result<()> {
    let mut event_listener = EventListener::new();

    event_listener.add_window_open_handler(|win| {
        let window_count = Workspace::get_active().unwrap().windows;
        match window_count {
            1 => force_fullscreen().unwrap(),
            2 if !IGNORE_WINDOW_CLASSES.iter().any(|v| *v == win.window_class) => {
                force_windowed().unwrap();
                Dispatch::call(DispatchType::FocusWindow(WindowIdentifier::Address(
                    win.window_address,
                )))
                .unwrap();
            }
            _ => {}
        }
    });
    event_listener.add_window_close_handler(|_| {
        let window_count = Workspace::get_active().unwrap().windows;
        match window_count {
            1 => force_fullscreen().unwrap(),
            _ => {}
        }
    });
    event_listener.start_listener()
}

fn better_movefocus(direction: Direction) -> hyprland::Result<()> {
    let is_fullscreen = FullscreenState::get()?.bool();
    if is_fullscreen {
        Dispatch::call(DispatchType::FocusMonitor(MonitorIdentifier::Direction(
            direction,
        )))?;
    } else {
        Dispatch::call(DispatchType::MoveFocus(direction))?;
    }
    Ok(())
}

const IGNORE_WINDOW_CLASSES: [&str; 2] = ["fcitx", ""];

fn main() -> hyprland::Result<()> {
    let cli = Cli::parse();

    match &cli.subcommands {
        Subcommands::Start => listen(),
        Subcommands::Movefocus { direction } => match direction {
            MoveFocusDirection::Up => better_movefocus(Direction::Up),
            MoveFocusDirection::Down => better_movefocus(Direction::Down),
            MoveFocusDirection::Left => better_movefocus(Direction::Left),
            MoveFocusDirection::Right => better_movefocus(Direction::Right),
        },
    }
}
