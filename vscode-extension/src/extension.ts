import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand('homebrew-cli-guide.openGuide', () => {
    vscode.window.showInformationMessage('Homebrew CLI Guide: Open Guide command (placeholder)');
  });
  context.subscriptions.push(disposable);
}

export function deactivate() {}
