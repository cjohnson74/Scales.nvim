# tests/test_scales.py
import os
import pytest
from scales import ScalesPractice

@pytest.fixture
def practice_tool():
    return ScalesPractice(practice_dir='/tmp/scales_test')

def test_generate_practice(practice_tool):
    session = practice_tool.generate_practice()
    
    assert 'filepath' in session
    assert os.path.exists(session['filepath'])
    assert session['filepath'].endswith('_practice.py')

def test_generate_specific_pattern(practice_tool):
    session = practice_tool.generate_practice('sliding_window')
    
    assert session['pattern'] == 'sliding_window'

def test_practice_log(practice_tool):
    initial_sessions = practice_tool.practice_log['total_sessions']
    practice_tool.generate_practice()
    
    assert practice_tool.practice_log['total_sessions'] == initial_sessions + 1

def test_validate_practice(practice_tool, tmp_path):
    # Create a template file
    template_path = tmp_path / 'template.py'
    template_path.write_text('''
def example_function(x):
    return x * 2
''')
    
    # Create a practice file
    practice_path = tmp_path / 'practice.py'
    practice_path.write_text('''
def example_function(x):
    return x * 2
''')
    
    # Validate
    results = practice_tool.validate_practice(str(template_path), str(practice_path))
    
    assert 'example_function' in results
    assert results['example_function']['status'] == 'PASS'