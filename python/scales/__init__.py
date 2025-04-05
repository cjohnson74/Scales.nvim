#!/usr/bin/env python3
import os
import json
import random
import argparse
from datetime import datetime
import difflib
import importlib.util
import sys

class ScalesPractice:
    def __init__(self, practice_dir=None):
        """
        Initialize the Scales practice system
        
        Args:
            practice_dir (str, optional): Directory to store practice sessions
        """
        # Use provided practice dir or default to a standard location
        self.practice_dir = practice_dir or os.path.expanduser('~/.local/share/nvim/scales')
        os.makedirs(self.practice_dir, exist_ok=True)
        
        # Practice log path
        self.log_path = os.path.join(self.practice_dir, 'practice_log.json')
        
        # Predefined practice patterns
        self.patterns = {
            'sliding_window': {
                'name': 'Sliding Window',
                'description': 'Practice sliding window technique',
                'templates': [
                    {
                        'name': 'Max Subarray Sum',
                        'language': 'python',
                        'template': '''
def max_subarray_sum(arr, k):
    """
    Find maximum sum of a contiguous subarray of size k
    
    Args:
        arr (list): Input array of integers
        k (int): Size of the sliding window
    
    Returns:
        int: Maximum sum of any contiguous subarray of size k
    """
    # TODO: Implement solution
    pass
'''
                    },
                    {
                        'name': 'Longest Substring',
                        'language': 'python',
                        'template': '''
def longest_substring(s, k):
    """
    Find length of longest substring with at most k distinct characters
    
    Args:
        s (str): Input string
        k (int): Maximum number of distinct characters
    
    Returns:
        int: Length of the longest substring
    """
    # TODO: Implement solution
    pass
'''
                    }
                ]
            },
            'two_pointers': {
                'name': 'Two Pointers',
                'description': 'Practice two-pointer technique',
                'templates': [
                    {
                        'name': 'Remove Duplicates',
                        'language': 'python',
                        'template': '''
def remove_duplicates(arr):
    """
    Remove duplicates in-place from sorted array
    
    Args:
        arr (list): Sorted input array
    
    Returns:
        int: Number of unique elements
    """
    # TODO: Implement solution
    pass
'''
                    },
                    {
                        'name': 'Pair with Target Sum',
                        'language': 'python',
                        'template': '''
def pair_with_target_sum(arr, target_sum):
    """
    Find two numbers in sorted array that add up to target sum
    
    Args:
        arr (list): Sorted input array
        target_sum (int): Target sum to find
    
    Returns:
        tuple: Indices of two numbers that add up to target, or None
    """
    # TODO: Implement solution
    pass
'''
                    }
                ]
            }
        }
        
        # Load or initialize practice log
        self.load_practice_log()
    
    def load_practice_log(self):
        """
        Load practice log from file or create a new one
        """
        try:
            with open(self.log_path, 'r') as f:
                self.practice_log = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            self.practice_log = {
                'total_sessions': 0,
                'patterns_practiced': {}
            }
    
    def save_practice_log(self):
        """
        Save practice log to file
        """
        with open(self.log_path, 'w') as f:
            json.dump(self.practice_log, f, indent=2)
    
    def generate_practice(self, pattern_name=None):
        """
        Generate a practice session
        
        Args:
            pattern_name (str, optional): Specific pattern to practice
        
        Returns:
            dict: Practice session details
        """
        # Choose pattern
        if not pattern_name:
            pattern_name = random.choice(list(self.patterns.keys()))
        
        pattern = self.patterns.get(pattern_name)
        if not pattern:
            raise ValueError(f"Pattern {pattern_name} not found")
        
        # Choose template
        template = random.choice(pattern['templates'])
        
        # Create practice file
        filename = f"{pattern_name}_{template['name'].lower().replace(' ', '_')}_practice.py"
        filepath = os.path.join(self.practice_dir, filename)
        
        # Write template
        with open(filepath, 'w') as f:
            f.write(template['template'])
        
        # Update practice log
        self.practice_log['total_sessions'] += 1
        self.practice_log['patterns_practiced'][pattern_name] = \
            self.practice_log['patterns_practiced'].get(pattern_name, 0) + 1
        self.save_practice_log()
        
        # Return session details
        return {
            'pattern': pattern_name,
            'template_name': template['name'],
            'filepath': filepath,
            'timestamp': datetime.now().isoformat()
        }
    
    def validate_practice(self, template_path, practice_path):
        """
        Validate practice implementation against template
        
        Args:
            template_path (str): Path to template file
            practice_path (str): Path to practice implementation
        
        Returns:
            dict: Validation results
        """
        def clean_code(code):
            """Remove comments and extra whitespace"""
            return [line.strip() for line in code.splitlines() 
                    if line.strip() and not line.strip().startswith('#')]
        
        # Import template module
        spec = importlib.util.spec_from_file_location("template", template_path)
        template_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(template_module)
        
        # Import practice module
        spec = importlib.util.spec_from_file_location("practice", practice_path)
        practice_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(practice_module)
        
        # Get functions from both modules
        template_funcs = {
            name: func for name, func in 
            [(name, func) for name, func in vars(template_module).items() 
             if callable(func) and not name.startswith('__')]
        }
        practice_funcs = {
            name: func for name, func in 
            [(name, func) for name, func in vars(practice_module).items() 
             if callable(func) and not name.startswith('__')]
        }
        
        # Validate each function
        results = {}
        for func_name, template_func in template_funcs.items():
            if func_name not in practice_funcs:
                results[func_name] = {
                    'status': 'MISSING',
                    'message': f'Function {func_name} not found in practice file'
                }
                continue
            
            practice_func = practice_funcs[func_name]
            
            # Compare function code
            try:
                template_code = clean_code(inspect.getsource(template_func))
                practice_code = clean_code(inspect.getsource(practice_func))
                
                # Compute differences
                diff = list(difflib.unified_diff(
                    template_code, 
                    practice_code, 
                    fromfile='template', 
                    tofile='practice'
                ))
                
                results[func_name] = {
                    'status': 'PASS' if not diff else 'PARTIAL',
                    'differences': diff if diff else None
                }
            except Exception as e:
                results[func_name] = {
                    'status': 'ERROR',
                    'message': str(e)
                }
        
        return results
    
    def get_practice_patterns(self):
        """
        Get available practice patterns
        
        Returns:
            list: Available pattern names
        """
        return list(self.patterns.keys())
    
    def get_progress(self):
        """
        Get practice progress
        
        Returns:
            dict: Practice progress information
        """
        return self.practice_log

def main():
    """
    Command-line interface for Scales practice tool
    """
    parser = argparse.ArgumentParser(description='Scales: Coding Practice Tool')
    
    # Add subcommands
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Generate practice command
    generate_parser = subparsers.add_parser('generate', help='Generate a practice session')
    generate_parser.add_argument('pattern', nargs='?', help='Specific pattern to practice')
    
    # Validate practice command
    validate_parser = subparsers.add_parser('validate', help='Validate practice implementation')
    validate_parser.add_argument('template', help='Path to template file')
    validate_parser.add_argument('practice', help='Path to practice file')
    
    # Progress command
    subparsers.add_parser('progress', help='Show practice progress')
    
    # Patterns command
    subparsers.add_parser('patterns', help='List available practice patterns')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Create practice instance
    practice = ScalesPractice()
    
    # Handle commands
    if args.command == 'generate':
        session = practice.generate_practice(args.pattern)
        print(f"Generated practice: {session['filepath']}")
    
    elif args.command == 'validate':
        results = practice.validate_practice(args.template, args.practice)
        
        # Print validation results
        for func_name, result in results.items():
            print(f"Function: {func_name}")
            print(f"Status: {result['status']}")
            
            if result['status'] == 'PARTIAL':
                print("Differences:")
                for diff_line in result.get('differences', []):
                    print(diff_line)
            elif result['status'] == 'MISSING' or result['status'] == 'ERROR':
                print(result.get('message', 'Unknown error'))
    
    elif args.command == 'progress':
        progress = practice.get_progress()
        print("Practice Progress:")
        print(f"Total Sessions: {progress['total_sessions']}")
        print("Patterns Practiced:")
        for pattern, count in progress['patterns_practiced'].items():
            print(f"  {pattern}: {count} sessions")
    
    elif args.command == 'patterns':
        print("Available Patterns:")
        for pattern in practice.get_practice_patterns():
            print(f"  {pattern}")
    
    else:
        parser.print_help()

if __name__ == '__main__':
    main()